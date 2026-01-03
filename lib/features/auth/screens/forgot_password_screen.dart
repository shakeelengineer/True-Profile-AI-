import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      // Simply call reset - the user will use the in-app reset screen
      await ref.read(authServiceProvider).resetPassword(
        _emailController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
        
        // Show additional instruction
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! After clicking the link in your email, return to the app to set your new password.'),
            backgroundColor: Color(0xFF00D9FF),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27), // Deep navy
              Color(0xFF0F1428), // Slightly lighter navy
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Top Bar: Back & Logo
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF141B2D),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00D9FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF0A0E27),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        children: const [
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
                  ],
                ),

                const SizedBox(height: 40),

                if (!_emailSent) ...[
                  // Lock Icon
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00D9FF).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFF00D9FF).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 48,
                        color: Color(0xFF00D9FF),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Heading
                  Text(
                    'Forgot Password?',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No worries! Enter your email address and we\'ll send you a link to reset your password.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFA1A1AA),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email
                        const Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'you@example.com',
                            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFA1A1AA)),
                            filled: true,
                            fillColor: const Color(0xFF141B2D),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1F2937)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF00D9FF)),
                            ),
                            hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Send Reset Link Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendResetEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D9FF),
                              foregroundColor: const Color(0xFF0A0E27),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Color(0xFF0A0E27)),
                                    ),
                                  )
                                : const Text(
                                    'Send Reset Link',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Success State
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00E676).withOpacity(0.1),
                            border: Border.all(
                              color: const Color(0xFF00E676).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.mark_email_read,
                            size: 48,
                            color: Color(0xFF00E676),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          'Check your email',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),

                        Text(
                          'We\'ve sent a password reset link to:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFA1A1AA),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),

                        Text(
                          _emailController.text.trim(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF00D9FF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Instructions Box
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141B2D),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3), width: 2),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: Color(0xFF00D9FF),
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Important Instructions',
                                      style: TextStyle(
                                        color: Color(0xFF00D9FF),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildStep('1', 'Click the link in your email'),
                              const SizedBox(height: 12),
                              _buildStep('2', 'Return to this app'),
                              const SizedBox(height: 12),
                              _buildStep('3', 'Go to Profile → Reset Password'),
                              const SizedBox(height: 12),
                              _buildStep('4', 'Enter your new password'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141B2D),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1F2937)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFFFDB241),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Didn\'t receive the email? Check your spam folder.',
                                  style: TextStyle(
                                    color: const Color(0xFFA1A1AA),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Resend Button
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _emailSent = false);
                          },
                          icon: const Icon(Icons.refresh, color: Color(0xFF00D9FF)),
                          label: const Text(
                            'Send Again',
                            style: TextStyle(
                              color: Color(0xFF00D9FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // Back to Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back, color: Color(0xFFA1A1AA), size: 16),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                          color: Color(0xFF00D9FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF00D9FF).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF00D9FF),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
