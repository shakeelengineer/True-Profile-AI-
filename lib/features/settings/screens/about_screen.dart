import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
      });
    } catch (e) {
      // Keep default version
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D9FF), Color(0xFF1AA2E6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D9FF).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App Name
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 28,
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
            
            const SizedBox(height: 8),
            
            // Version
            Text(
              'Version $_version',
              style: const TextStyle(
                color: Color(0xFFA1A1AA),
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Description Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141B2D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'About True-Profile AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'True-Profile AI is an advanced profile verification platform that leverages artificial intelligence to automate and streamline identity verification, resume analysis, and skill assessment processes.',
                    style: TextStyle(
                      color: Color(0xFFA1A1AA),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Features
            _buildFeatureCard(
              'Identity Verification',
              'AI-powered face recognition technology to verify profile authenticity and consistency',
              Icons.verified_user,
              const Color(0xFF00D9FF),
            ),
            
            const SizedBox(height: 16),
            
            _buildFeatureCard(
              'Resume Analysis',
              'ATS compatibility scoring and detailed feedback to improve your resume',
              Icons.description,
              const Color(0xFF7C3AED),
            ),
            
            const SizedBox(height: 16),
            
            _buildFeatureCard(
              'Skill Verification',
              'AI-generated quizzes to validate and certify your professional skills',
              Icons.school,
              const Color(0xFFEC4899),
            ),
            
            const SizedBox(height: 32),
            
            // Tech Stack
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141B2D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Built With',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTechItem('Flutter', 'Cross-platform mobile framework'),
                  _buildTechItem('Supabase', 'Backend & Authentication'),
                  _buildTechItem('AI/ML', 'Advanced verification algorithms'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Social/Contact
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141B2D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Get in Touch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(Icons.email, 'support@trueprofileai.com'),
                  const SizedBox(height: 12),
                  _buildContactItem(Icons.language, 'www.trueprofileai.com'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Copyright
            Text(
              '© 2026 True-Profile AI\nAll rights reserved',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFA1A1AA),
                fontSize: 12,
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00D9FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00D9FF), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFA1A1AA),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
