import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// Updated Splash Screen matching True-Profile AI design
/// Colors: Deep dark navy background with cyan/turquoise accents
/// Layout: Left-aligned content with specific buttons
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Fade animation for overall content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimationSequence() async {
    // Start fade animation
    _fadeController.forward();
    
    // Slight delay for slide
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Top Logo Row
              FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00D9FF),
                        shape: BoxShape.circle,
                        boxShadow: [
                           BoxShadow(
                            color: Color(0x3300D9FF),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF0A0E27),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18,
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
              ),

              const Spacer(flex: 2),

              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1F2C),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFF004D5C),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF00D9FF),
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI-Powered Verification',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF00D9FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Heading
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            height: 1.1,
                          ),
                          children: const [
                            TextSpan(text: 'Build Trust with\n'),
                            TextSpan(
                              text: 'Verified',
                              style: TextStyle(color: Color(0xFF00D9FF)),
                            ),
                            TextSpan(text: ' Profiles'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Description
                      Text(
                        'Verify your identity, validate your skills,\nand showcase an authentic professional\nprofile powered by AI.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFA1A1AA),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Features
                      _buildFeatureItem(context, 'Face Verification', 'AI-powered identity matching'),
                      const SizedBox(height: 16),
                      _buildFeatureItem(context, 'Resume Scoring', 'ATS-style analysis & tips'),
                      const SizedBox(height: 16),
                      _buildFeatureItem(context, 'Skill Validation', 'Quiz-based assessments'),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Bottom Buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                           context.go('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D9FF),
                          foregroundColor: const Color(0xFF0A0E27),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFA1A1AA),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                             context.go('/login');
                          },
                          child: const Text(
                            'Sign In',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF00D9FF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$title – ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: subtitle,
                  style: const TextStyle(
                    color: Color(0xFFA1A1AA),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}