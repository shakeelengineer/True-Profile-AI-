import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../services/skill_quiz_service.dart';

class SkillVerificationScreen extends ConsumerStatefulWidget {
  const SkillVerificationScreen({super.key});

  @override
  ConsumerState<SkillVerificationScreen> createState() => _SkillVerificationScreenState();
}

class _SkillVerificationScreenState extends ConsumerState<SkillVerificationScreen> {
  final SkillQuizService _quizService = SkillQuizService();
  
  // Expanded list with categories and icons for CS/SE/AI students
  final List<Map<String, dynamic>> _topics = [
    {'name': 'Python', 'icon': Icons.code, 'category': 'Programming'},
    {'name': 'Java', 'icon': Icons.coffee_rounded, 'category': 'Programming'},
    {'name': 'Data Structures', 'icon': Icons.account_tree_rounded, 'category': 'CS Core'},
    {'name': 'Algorithms', 'icon': Icons.functions_rounded, 'category': 'CS Core'},
    {'name': 'Operating Systems', 'icon': Icons.settings_suggest_rounded, 'category': 'CS Core'},
    {'name': 'Computer Networks', 'icon': Icons.lan_rounded, 'category': 'CS Core'},
    {'name': 'Cybersecurity', 'icon': Icons.security_rounded, 'category': 'Security'},
    {'name': 'Machine Learning', 'icon': Icons.analytics_rounded, 'category': 'AI'},
    {'name': 'Artificial Intelligence', 'icon': Icons.psychology_rounded, 'category': 'AI'},
    {'name': 'Data Science', 'icon': Icons.bar_chart_rounded, 'category': 'Data'},
    {'name': 'SQL', 'icon': Icons.storage_rounded, 'category': 'Database'},
    {'name': 'Flutter', 'icon': Icons.smartphone_rounded, 'category': 'Development'},
    {'name': 'React', 'icon': Icons.web_rounded, 'category': 'Development'},
    {'name': 'Node.js', 'icon': Icons.javascript_rounded, 'category': 'Development'},
    {'name': 'AWS', 'icon': Icons.cloud_rounded, 'category': 'Cloud'},
    {'name': 'DevOps', 'icon': Icons.integration_instructions_rounded, 'category': 'SE'},
    {'name': 'Software Testing', 'icon': Icons.bug_report_rounded, 'category': 'SE'},
  ];

  String? _selectedSkill;
  bool _isLoadingQuiz = false;
  bool _quizStarted = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  bool _isSaving = false;
  
  List<Map<String, dynamic>> _questions = [];
  int _passingScore = 80;

  Future<void> _generateAndStartQuiz() async {
    if (_selectedSkill == null) {
      _showError('Please select a topic first');
      return;
    }

    setState(() {
      _isLoadingQuiz = true;
    });

    try {
      final quizData = await _quizService.generateQuiz(_selectedSkill!);
      
      // Record the start of the assessment as "pending"
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('verification_results').insert({
          'user_id': user.id,
          'verification_type': 'skills',
          'status': 'pending',
          'data': {'skill': _selectedSkill},
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      setState(() {
        _questions = List<Map<String, dynamic>>.from(quizData['questions']);
        _passingScore = quizData['passing_score'] ?? 80;
        _quizStarted = true;
        _currentQuestionIndex = 0;
        _score = 0;
        _quizCompleted = false;
        _isLoadingQuiz = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingQuiz = false);
      _showError('Failed to generate quiz: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _saveSkillResults() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final percentage = ((_score / _questions.length) * 100).toInt();
        final passed = percentage >= _passingScore;
        
        await Supabase.instance.client.from('verification_results').insert({
          'user_id': user.id,
          'verification_type': 'skills',
          'status': passed ? 'verified' : 'completed',
          'score': percentage,
          'data': {
            'skill': _selectedSkill,
            'correct_answers': _score,
            'total_questions': _questions.length,
            'passed': passed,
            'passing_score': _passingScore,
          },
          'feedback': [
            'Assessment completed with $percentage% accuracy',
            if (passed) 'Congratulations! You earned the $_selectedSkill badge!'
            else 'Keep practicing! You need $_passingScore% to earn the badge.'
          ],
          'updated_at': DateTime.now().toIso8601String(),
        });

        if (passed) {
          await _saveBadge(user.id, percentage);
        }
      }
    } catch (e) {
      debugPrint('Error saving results: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveBadge(String userId, int score) async {
    try {
      final existing = await Supabase.instance.client
          .from('skill_badges')
          .select()
          .eq('user_id', userId)
          .eq('skill_name', _selectedSkill!)
          .maybeSingle();

      if (existing == null) {
        await Supabase.instance.client.from('skill_badges').insert({
          'user_id': userId,
          'skill_name': _selectedSkill!,
          'badge_type': 'verified',
          'score': score,
          'earned_at': DateTime.now().toIso8601String(),
        });
      } else if (score > (existing['score'] ?? 0)) {
        await Supabase.instance.client
            .from('skill_badges')
            .update({
              'score': score,
              'earned_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('skill_name', _selectedSkill!);
      }
    } catch (e) {
      debugPrint('Error saving badge: $e');
    }
  }

  void _answerQuestion(int selectedIndex) async {
    if (selectedIndex == _questions[_currentQuestionIndex]['answer']) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
      await _saveSkillResults();
    }
  }

  void _resetQuiz() {
    setState(() {
      _selectedSkill = null;
      _quizStarted = false;
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
      _questions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Skill Validation', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _quizStarted && !_quizCompleted
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _resetQuiz,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _quizCompleted
              ? _buildResultsView(theme)
              : _quizStarted
                  ? _buildQuizView(theme)
                  : _buildSelectionView(theme),
        ),
      ),
    );
  }

  Widget _buildSelectionView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(
          'Validate Your Skills',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a domain to start your AI-powered assessment. Reach 80% to earn a verified professional badge.',
          style: TextStyle(
            fontSize: 15,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: _topics.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final topic = _topics[index];
              final isSelected = _selectedSkill == topic['name'];
              return InkWell(
                onTap: () => setState(() => _selectedSkill = topic['name']),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? theme.primaryColor : theme.colorScheme.outline.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.2) : theme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          topic['icon'],
                          color: isSelected ? Colors.white : theme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic['name'],
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              topic['category'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white.withOpacity(0.7) : theme.colorScheme.onSurface.withOpacity(0.4),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.2),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        if (_isLoadingQuiz)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: [
                  CircularProgressIndicator(color: theme.primaryColor),
                  const SizedBox(height: 12),
                  Text('Preparing assessment...', style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton(
              onPressed: _selectedSkill == null ? null : _generateAndStartQuiz,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                backgroundColor: theme.primaryColor,
                disabledBackgroundColor: theme.colorScheme.surface,
              ),
              child: const Text(
                'START ASSESSMENT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuizView(ThemeData theme) {
    if (_questions.isEmpty) return const Center(child: CircularProgressIndicator());
    final question = _questions[_currentQuestionIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedSkill?.toUpperCase() ?? '',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${((_currentQuestionIndex + 1) / _questions.length * 100).toInt()}%',
                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
          backgroundColor: theme.colorScheme.surface,
          color: theme.primaryColor,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 48),
        Text(
          question['question'],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.4),
        ),
        const SizedBox(height: 48),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: question['options'].length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: InkWell(
                  onTap: () => _answerQuestion(index),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            question['options'][index],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView(ThemeData theme) {
    final percentage = ((_score / _questions.length) * 100).toInt();
    final passed = percentage >= _passingScore;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: passed ? const Color(0xFF10B981).withOpacity(0.1) : theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              passed ? Icons.emoji_events_rounded : Icons.cancel_rounded,
              size: 100,
              color: passed ? const Color(0xFF10B981) : theme.primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            passed ? 'VERIFIED EXPERT!' : 'ASSESSMENT COMPLETE',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Text(
            passed
                ? 'Great job! You\'ve successfully earned the $_selectedSkill verified badge.'
                : 'You scored $percentage%. Keep practicing to reach the 80% verification threshold.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6), height: 1.5),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    color: passed ? const Color(0xFF10B981) : theme.primaryColor,
                  ),
                ),
                Text(
                  'ACCURACY SCORE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          if (_isSaving)
            const CircularProgressIndicator()
          else
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(22),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: theme.primaryColor,
                    ),
                    child: const Text('RETURN TO DASHBOARD', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _resetQuiz,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(22),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(color: theme.primaryColor, width: 2),
                    ),
                    child: Text(
                      'TRY ANOTHER TOPIC',
                      style: TextStyle(fontWeight: FontWeight.w900, color: theme.primaryColor),
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
