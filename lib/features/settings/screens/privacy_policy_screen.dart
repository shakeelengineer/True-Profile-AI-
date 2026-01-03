import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Introduction',
              'True-Profile AI is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your personal information when you use our AI-powered profile verification services.',
            ),
            
            _buildSection(
              '1. Information We Collect',
              'We collect the following types of information:\n\n'
              '• Personal Information: Name, email address, phone number\n'
              '• Identity Verification Data: Profile photos for AI face verification\n'
              '• Professional Data: Resume files for ATS analysis\n'
              '• Skill Assessment Data: Quiz responses and scores\n'
              '• Account Information: Login credentials (securely hashed)',
            ),
            
            _buildSection(
              '2. How We Use Your Information',
              'We use your information to:\n\n'
              '• Verify your identity using AI-powered face recognition\n'
              '• Analyze your resume for ATS compatibility\n'
              '• Generate and evaluate skill assessments\n'
              '• Provide you with verification results and certificates\n'
              '• Improve our AI models and services\n'
              '• Send you important account updates and notifications',
            ),
            
            _buildSection(
              '3. AI and Data Processing',
              'Your data is processed using advanced AI technologies:\n\n'
              '• Face Verification: Your photos are analyzed using secure AI algorithms to verify identity consistency\n'
              '• Resume Analysis: Your resume is processed to provide ATS scores and feedback\n'
              '• Quiz Generation: AI generates personalized skill assessment questions\n'
              '• All AI processing is done securely and your data is never shared with third parties for training purposes without consent',
            ),
            
            _buildSection(
              '4. Data Storage and Security',
              '• All data is stored securely using Supabase (PostgreSQL database)\n'
              '• Passwords are encrypted using industry-standard hashing\n'
              '• Files are stored in secure cloud storage with encryption\n'
              '• We implement SSL/TLS encryption for all data transmission\n'
              '• Regular security audits are performed',
            ),
            
            _buildSection(
              '5. Data Retention',
              '• Account data is retained as long as your account is active\n'
              '• Verification results are stored for your reference\n'
              '• You can request deletion of your data at any time\n'
              '• Deleted data is permanently removed within 30 days',
            ),
            
            _buildSection(
              '6. Your Rights',
              'You have the right to:\n\n'
              '• Access your personal data\n'
              '• Correct inaccurate data\n'
              '• Request deletion of your data\n'
              '• Export your data\n'
              '• Opt-out of non-essential communications\n'
              '• Withdraw consent for data processing',
            ),
            
            _buildSection(
              '7. Third-Party Services',
              'We use the following third-party services:\n\n'
              '• Supabase: Authentication and database hosting\n'
              '• Cloud Storage: For secure file storage\n'
              '• AI Services: For face verification and content analysis\n\n'
              'These services comply with industry security standards and privacy regulations.',
            ),
            
            _buildSection(
              '8. Children\'s Privacy',
              'True-Profile AI is not intended for users under 18 years of age. We do not knowingly collect personal information from children.',
            ),
            
            _buildSection(
              '9. Changes to Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any significant changes via email or app notification.',
            ),
            
            _buildSection(
              '10. Contact Us',
              'If you have questions about this Privacy Policy or your data, please contact us at:\n\n'
              'Email: privacy@trueprofileai.com\n\n'
              'Last Updated: January 1, 2026',
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141B2D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.shield, color: Color(0xFF00D9FF), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your privacy and security are our top priorities. We are committed to protecting your data.',
                      style: TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFFA1A1AA),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
