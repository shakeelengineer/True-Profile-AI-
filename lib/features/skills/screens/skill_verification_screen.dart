import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class SkillVerificationScreen extends ConsumerStatefulWidget {
  const SkillVerificationScreen({super.key});

  @override
  ConsumerState<SkillVerificationScreen> createState() => _SkillVerificationScreenState();
}

class _SkillVerificationScreenState extends ConsumerState<SkillVerificationScreen> {
  final List<String> _availableSkills = [
    'Python', 'Flutter', 'Data Science', 'React', 'Node.js', 
    'Machine Learning', 'SQL', 'AWS'
  ];
  final Set<String> _selectedSkills = {};
  bool _quizStarted = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _mockQuestions = [
    {
      'question': 'What is the primary function of "setState" in Flutter?',
      'options': [
        'To build the widget tree',
        'To notify the framework that the internal state has changed',
        'To navigate to a new screen',
        'To make an API call'
      ],
      'answer': 1
    },
    {
      'question': 'Which widget is used to create a scrollable list?',
      'options': ['Container', 'Column', 'ListView', 'Stack'],
      'answer': 2
    },
    {
      'question': 'What does "await" do in Dart?',
      'options': [
        'Stops the program execution forever',
        'Waits for a Future to complete',
        'Starts a background thread',
        'Declares a variable'
      ],
      'answer': 1
    },
  ];

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  void _startQuiz() {
    setState(() {
      _quizStarted = true;
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
    });
  }

  Future<void> _saveSkillResults() async {
    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final percentage = ((_score / _mockQuestions.length) * 100).toInt();
        await Supabase.instance.client.from('verification_results').insert({
          'user_id': user.id,
          'verification_type': 'skills',
          'status': 'completed',
          'score': percentage,
          'data': {
            'skills_verified': _selectedSkills.toList(),
            'correct_answers': _score,
            'total_questions': _mockQuestions.length,
          },
          'feedback': ['Assessment completed with $percentage% accuracy'],
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error saving results: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _answerQuestion(int selectedIndex) async {
    if (selectedIndex == _mockQuestions[_currentQuestionIndex]['answer']) {
      _score++;
    }

    if (_currentQuestionIndex < _mockQuestions.length - 1) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Skill Validation', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          padding: const EdgeInsets.all(24.0),
          child: _quizStarted ? _buildQuizView(theme) : _buildSelectionView(theme),
        ),
      ),
    );
  }

  Widget _buildSelectionView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.psychology_alt_rounded, color: theme.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Select core competencies for AI assessment. Passing unlocks premium trust badges.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('CORE DOMAINS', style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableSkills.map((skill) {
            final isSelected = _selectedSkills.contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: isSelected,
              onSelected: (_) => _toggleSkill(skill),
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.primaryColor.withOpacity(0.2),
              checkmarkColor: theme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSelected ? theme.primaryColor : theme.colorScheme.outline.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _selectedSkills.isEmpty ? null : _startQuiz,
          icon: const Icon(Icons.bolt_rounded),
          label: const Text('ENGAGE ASSESSMENT'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizView(ThemeData theme) {
    if (_quizCompleted) {
      final percentage = ((_score / _mockQuestions.length) * 100).toInt();
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor.withOpacity(0.3), width: 2),
              ),
              child: Icon(Icons.auto_awesome_rounded, size: 80, color: theme.primaryColor),
            ),
            const SizedBox(height: 32),
            const Text('EVALUATION COMPLETE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Text('Precision Score: $percentage%', style: TextStyle(fontSize: 18, color: theme.primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 48),
            if (_isSaving)
              const CircularProgressIndicator()
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('RETURN TO DASHBOARD'),
                ),
              ),
          ],
        ),
      );
    }

    final question = _mockQuestions[_currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ASSESSMENT ENGINE', style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
            Text('${_currentQuestionIndex + 1} / ${_mockQuestions.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _mockQuestions.length,
            backgroundColor: theme.colorScheme.surface,
            color: theme.primaryColor,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          question['question'],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
        ),
        const SizedBox(height: 40),
        ...List.generate(question['options'].length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: OutlinedButton(
              onPressed: () => _answerQuestion(index),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.centerLeft,
                side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
              ),
              child: Text(
                question['options'][index],
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          );
        }),
      ],
    );
  }
}
