import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Results'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00D9FF),
          labelColor: const Color(0xFF00D9FF),
          unselectedLabelColor: const Color(0xFFA1A1AA),
          tabs: const [
            Tab(text: 'Identity'),
            Tab(text: 'Resume'),
            Tab(text: 'Skills'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIdentityResults(),
          _buildResumeResults(),
          _buildSkillsResults(),
        ],
      ),
    );
  }

  Widget _buildIdentityResults() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildResultCard(
          title: 'Face Verification',
          date: 'Dec 28, 2025',
          status: 'Pending',
          statusColor: const Color(0xFFFDB241),
          icon: Icons.face,
          details: 'AI analysis in progress. You will be notified once verification is complete.',
        ),
        const SizedBox(height: 16),
        _buildResultCard(
          title: 'Previous Verification',
          date: 'Dec 15, 2025',
          status: 'Rejected',
          statusColor: Colors.red,
          icon: Icons.face,
          details: 'Images were not clear enough. Please submit new photos.',
        ),
      ],
    );
  }

  Widget _buildResumeResults() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildAtsScoreCard(
          fileName: 'John_Doe_Resume.pdf',
          date: 'Dec 30, 2025',
          score: 85,
          feedback: [
            'Strong keyword optimization',
            'Good formatting and structure',
            'Consider adding more quantifiable achievements',
          ],
        ),
        const SizedBox(height: 16),
        _buildAtsScoreCard(
          fileName: 'Resume_v1.pdf',
          date: 'Dec 10, 2025',
          score: 62,
          feedback: [
            'Weak keyword density',
            'Poor formatting detected',
            'Missing contact information',
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsResults() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSkillResultCard(
          skill: 'Flutter',
          date: 'Dec 29, 2025',
          score: 90,
          questionsTotal: 10,
          questionsCorrect: 9,
          level: 'Advanced',
        ),
        const SizedBox(height: 16),
        _buildSkillResultCard(
          skill: 'Python',
          date: 'Dec 20, 2025',
          score: 75,
          questionsTotal: 10,
          questionsCorrect: 7,
          level: 'Intermediate',
        ),
        const SizedBox(height: 16),
        _buildSkillResultCard(
          skill: 'React',
          date: 'Dec 15, 2025',
          score: 60,
          questionsTotal: 10,
          questionsCorrect: 6,
          level: 'Beginner',
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required IconData icon,
    required String details,
  }) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: statusColor, size: 24),
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
                      date,
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E27),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              details,
              style: const TextStyle(
                color: Color(0xFFA1A1AA),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtsScoreCard({
    required String fileName,
    required String date,
    required int score,
    required List<String> feedback,
  }) {
    Color scoreColor;
    String rating;
    
    if (score >= 80) {
      scoreColor = const Color(0xFF00E676);
      rating = 'Excellent';
    } else if (score >= 60) {
      scoreColor = const Color(0xFFFDB241);
      rating = 'Good';
    } else {
      scoreColor = Colors.red;
      rating = 'Needs Improvement';
    }

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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description, color: scoreColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
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
          const SizedBox(height: 20),
          
          // Score Display
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scoreColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score',
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ATS Score',
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E27),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        score >= 80 ? Icons.emoji_events : Icons.trending_up,
                        color: scoreColor,
                        size: 36,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rating,
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Feedback
          const Text(
            'Feedback:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...feedback.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 6,
                      color: Color(0xFF00D9FF),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSkillResultCard({
    required String skill,
    required String date,
    required int score,
    required int questionsTotal,
    required int questionsCorrect,
    required String level,
  }) {
    Color levelColor;
    
    if (score >= 80) {
      levelColor = const Color(0xFF00E676);
    } else if (score >= 60) {
      levelColor = const Color(0xFFFDB241);
    } else {
      levelColor = Colors.red;
    }

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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.school, color: levelColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    color: levelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: $score%',
                    style: TextStyle(
                      color: levelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$questionsCorrect/$questionsTotal correct',
                    style: const TextStyle(
                      color: Color(0xFFA1A1AA),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: const Color(0xFF0A0E27),
                  color: levelColor,
                  minHeight: 8,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Certificate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00D9FF),
                    side: const BorderSide(color: Color(0xFF00D9FF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retake'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9FF),
                    foregroundColor: const Color(0xFF0A0E27),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
