import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/services/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider).value;
    final user = authState?.session?.user;
    final userName = user?.email?.split('@').first ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar with Profile
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Logo
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00D9FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: Color(0xFF0A0E27),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: 'True-Profile ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'AI',
                                style: TextStyle(color: Color(0xFF00D9FF)),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Notifications
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF141B2D),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            color: Colors.white,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Profile Avatar
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00D9FF), Color(0xFF1AA2E6)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00D9FF).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                userName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Welcome Message
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: const Color(0xFFA1A1AA),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName.substring(0, 1).toUpperCase() + userName.substring(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '3',
                            'Verifications',
                            Icons.verified_user,
                            const Color(0xFF00D9FF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '67%',
                            'Profile Complete',
                            Icons.pie_chart,
                            const Color(0xFFFDB241),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Verification Progress
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Verification Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProgressCard(),
                  ],
                ),
              ),
            ),
            
            // Features Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Verification Services',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/results'),
                          child: const Text(
                            'View All',
                            style: TextStyle(color: Color(0xFF00D9FF)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Feature Cards Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildFeatureCard(
                    context,
                    title: 'Identity Verification',
                    description: 'AI-powered face verification',
                    icon: Icons.face,
                    route: '/identity',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D9FF), Color(0xFF1AA2E6)],
                    ),
                    status: 'Pending',
                    statusColor: const Color(0xFFFDB241),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    title: 'Resume Analysis',
                    description: 'Get instant ATS compatibility score',
                    icon: Icons.description,
                    route: '/resume',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                    ),
                    status: 'Not Started',
                    statusColor: const Color(0xFFA1A1AA),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    title: 'Skill Verification',
                    description: 'Prove your skills with AI quizzes',
                    icon: Icons.school,
                    route: '/skills',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
                    ),
                    status: 'Completed',
                    statusColor: const Color(0xFF00E676),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141B2D),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', true, () {}),
                _buildNavItem(Icons.assessment, 'Results', false, () => context.push('/results')),
                _buildNavItem(Icons.person, 'Profile', false, () => context.push('/profile')),
                _buildNavItem(Icons.logout, 'Logout', false, () {
                  ref.read(authServiceProvider).signOut();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA1A1AA),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2 of 3 Completed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '67%',
                style: TextStyle(
                  color: const Color(0xFF00D9FF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.67,
              backgroundColor: const Color(0xFF0A0E27),
              color: const Color(0xFF00D9FF),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressItem('Identity Verification', true, const Color(0xFFFDB241)),
          const SizedBox(height: 8),
          _buildProgressItem('Resume Analysis', false, const Color(0xFFA1A1AA)),
          const SizedBox(height: 8),
          _buildProgressItem('Skill Verification', true, const Color(0xFF00E676)),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String title, bool completed, Color color) {
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: completed ? Colors.white : const Color(0xFFA1A1AA),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String route,
    required Gradient gradient,
    required String status,
    required Color statusColor,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF141B2D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFFA1A1AA),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFA1A1AA),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF00D9FF) : const Color(0xFFA1A1AA),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF00D9FF) : const Color(0xFFA1A1AA),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
