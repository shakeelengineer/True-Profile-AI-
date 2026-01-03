import 'package:flutter/material.dart';

class SkillVerificationScreen extends StatefulWidget {
  const SkillVerificationScreen({super.key});

  @override
  State<SkillVerificationScreen> createState() => _SkillVerificationScreenState();
}

class _SkillVerificationScreenState extends State<SkillVerificationScreen> {
  final List<String> _availableSkills = [
    'Python',
    'Flutter',
    'Data Science',
    'React',
    'Node.js',
    'Machine Learning',
    'SQL',
    'AWS'
  ];
  final Set<String> _selectedSkills = {};
  bool _quizStarted = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;

  // Mock Quiz Data
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

  void _answerQuestion(int selectedIndex) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _quizStarted
            ? _buildQuizView()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Select skills you want to verify. We will generate a quick AI quiz to assess your proficiency.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Select Skills:', 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                    )
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableSkills.map((skill) {
                      final isSelected = _selectedSkills.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: isSelected,
                        onSelected: (_) => _toggleSkill(skill),
                        checkmarkColor: Theme.of(context).colorScheme.onSecondary,
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Theme.of(context).colorScheme.outline,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _selectedSkills.isEmpty ? null : _startQuiz,
                    icon: const Icon(Icons.school),
                    label: const Text('Start Assessment'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuizView() {
    if (_quizCompleted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            const Text('Assessment Complete!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('You scored $_score / ${_mockQuestions.length}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => setState(() => _quizStarted = false),
              child: const Text('Back to Skills'),
            )
          ],
        ),
      );
    }

    final question = _mockQuestions[_currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _mockQuestions.length,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 24),
        Text(
          'Question ${_currentQuestionIndex + 1}/${_mockQuestions.length}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 8),
        Text(
          question['question'],
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 32),
        ...List.generate(question['options'].length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: OutlinedButton(
              onPressed: () => _answerQuestion(index),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(question['options'][index], 
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16
                )
              ),
            ),
          );
        }),
      ],
    );
  }
}
