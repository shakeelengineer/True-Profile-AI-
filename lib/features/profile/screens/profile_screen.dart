import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/services/auth_service.dart';
import '../../dashboard/services/verification_provider.dart';
import '../../skills/widgets/skill_badges_widget.dart';
import '../../identity/screens/face_capture_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      _nameController.text = user.userMetadata?['full_name'] ?? '';
      _phoneController.text = user.phone ?? '';
      _bioController.text = user.userMetadata?['bio'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    
    try {
      await ref.read(authServiceProvider).updateProfile(
        fullName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider).value;
    final user = authState?.session?.user;
    final theme = Theme.of(context);
    final verificationStatus = ref.watch(verificationProvider);

    // Get display name for initial
    String displayInitial = 'U';
    if (user != null) {
      final fullName = user.userMetadata?['full_name']?.toString();
      if (fullName != null && fullName.isNotEmpty) {
        displayInitial = fullName.substring(0, 1).toUpperCase();
      } else if (user.email != null) {
        displayInitial = user.email!.substring(0, 1).toUpperCase();
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_rounded, color: theme.primaryColor, size: 20),
                ),
                onPressed: () => setState(() => _isEditing = true),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _isSaving 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : TextButton(
                    onPressed: _saveProfile,
                    child: Text('Done', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                  ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Picture Section
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 8,
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 4),
                  ),
                  child: Center(
                    child: (user?.userMetadata?['avatar_url'] != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(65),
                            child: Image.network(
                              user!.userMetadata!['avatar_url'],
                              key: ValueKey(user.userMetadata!['avatar_url']), // Force refresh
                              width: 130,
                              height: 130,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Image Load Error: $error');
                                return Text(
                                  displayInitial,
                                  style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white),
                                );
                              },
                            ),
                          )
                        : Text(
                            displayInitial,
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => context.push('/face-capture'),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // User Email
            Text(
              user?.email ?? 'user@example.com',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.1,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Verification Status Row
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              child: verificationStatus.when(
                data: (status) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusItem(
                      theme, 
                      'Identity', 
                      Icons.verified_user_rounded, 
                      VerificationStatus.getStatusLabel(status.identityStatus), 
                      VerificationStatus.getStatusColor(status.identityStatus, theme)
                    ),
                    _buildStatusDivider(theme),
                    _buildStatusItem(
                      theme, 
                      'Resume', 
                      Icons.description_rounded, 
                      VerificationStatus.getStatusLabel(status.resumeStatus), 
                      VerificationStatus.getStatusColor(status.resumeStatus, theme)
                    ),
                    _buildStatusDivider(theme),
                    _buildStatusItem(
                      theme, 
                      'Skills', 
                      Icons.psychology_rounded, 
                      VerificationStatus.getStatusLabel(status.skillsStatus), 
                      VerificationStatus.getStatusColor(status.skillsStatus, theme)
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading status'),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Profile Information
            _buildSectionHeader(theme, 'Account Basics'),
            const SizedBox(height: 16),
            
            _buildTextField(
              theme: theme,
              controller: _nameController,
              label: 'Display Name',
              icon: Icons.person_rounded,
              enabled: _isEditing,
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              theme: theme,
              controller: _phoneController,
              label: 'Connect Phone',
              icon: Icons.phone_rounded,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              theme: theme,
              controller: _bioController,
              label: 'Professional Bio',
              icon: Icons.auto_awesome_rounded,
              enabled: _isEditing,
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            // Skill Badges Section
            _buildSectionHeader(theme, 'Verified Badges'),
            const SizedBox(height: 16),
            const SkillBadgesWidget(),
            
            const SizedBox(height: 32),
            
            // Actions
            _buildSectionHeader(theme, 'Security & Legal'),
            const SizedBox(height: 16),
            
            _buildActionTile(theme, 'Change Access Token', Icons.lock_person_rounded, () => context.push('/reset-password')),
            const SizedBox(height: 12),
            _buildActionTile(theme, 'Privacy Charter', Icons.gavel_rounded, () => context.push('/privacy-policy')),
            const SizedBox(height: 12),
            _buildActionTile(theme, 'Project Genesis', Icons.info_rounded, () => context.push('/about')),
            
            const SizedBox(height: 40),
            
            // Logout
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () => ref.read(authServiceProvider).signOut(),
                icon: const Icon(Icons.power_settings_new_rounded),
                label: const Text('DISCONNECT ACCOUNT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(ThemeData theme, String title, IconData icon, String status, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.6))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _buildStatusDivider(ThemeData theme) {
    return Container(height: 30, width: 1, color: theme.colorScheme.outline.withOpacity(0.2));
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: theme.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: enabled ? Colors.white : Colors.white38),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: enabled ? theme.primaryColor : Colors.white24),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3))
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide(color: theme.primaryColor, width: 2)
        ),
      ),
    );
  }

  Widget _buildActionTile(ThemeData theme, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      tileColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: theme.primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withOpacity(0.3)),
    );
  }
}
