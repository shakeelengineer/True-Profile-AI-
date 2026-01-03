import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/resume_service.dart';

class ResumeAnalysisScreen extends StatefulWidget {
  const ResumeAnalysisScreen({super.key});

  @override
  State<ResumeAnalysisScreen> createState() => _ResumeAnalysisScreenState();
}

class _ResumeAnalysisScreenState extends State<ResumeAnalysisScreen> {
  final _resumeService = ResumeService();
  PlatformFile? _pickedFile;
  bool _isAnalyzing = false;
  String _scanningStep = '';
  double _scanningProgress = 0.0;
  Map<String, dynamic>? _analysisResults;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
        _analysisResults = null;
      });
    }
  }

  Future<void> _analyzeResume() async {
    if (_pickedFile == null || _pickedFile!.path == null) return;

    setState(() {
      _isAnalyzing = true;
      _scanningProgress = 0.0;
      _analysisResults = null;
    });
    
    final steps = [
      'Stripping PII for bias-free screening...',
      'Extracting section headers...',
      'Analyzing Education & Experience...',
      'Detecting industry-specific keywords...',
      'Calculating ATS compatibility score...',
      'Generating explainable feedback...'
    ];

    try {
      final file = File(_pickedFile!.path!);
      
      // We'll call the API first, then simulate the UI steps for a better experience
      final apiResult = await _resumeService.analyzeResume(file);

      for (int i = 0; i < steps.length; i++) {
        if (!mounted) return;
        setState(() {
          _scanningStep = steps[i];
          _scanningProgress = (i + 1) / steps.length;
        });
        await Future.delayed(const Duration(milliseconds: 800));
      }
      
      if (apiResult != null && mounted) {
        setState(() {
          _analysisResults = apiResult;
          _isAnalyzing = false;
        });

        final user = Supabase.instance.client.auth.currentUser;
        if (user != null && apiResult['resume_score'] != null) {
          await _resumeService.saveAnalysisResult(
            userId: user.id,
            score: (apiResult['resume_score'] as num).toInt(),
            skills: apiResult['skills_detected'] ?? [],
            strengths: apiResult['strengths'] ?? [],
            weaknesses: apiResult['weaknesses'] ?? [],
            suggestions: apiResult['suggestions'] ?? [],
            feedback: apiResult['ats_feedback'] ?? '',
          );
        }
      } else {
        if (mounted) {
          setState(() => _isAnalyzing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to analyze resume. Please check your internet or Supabase connection.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('JustScreen AI Analyzer', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFairnessBanner(),
                const SizedBox(height: 24),
                if (_pickedFile != null && !_isAnalyzing && _analysisResults == null) 
                  _buildFilePreview()
                else if (_analysisResults == null && !_isAnalyzing)
                  _buildUploadZone(),
                
                if (_isAnalyzing)
                  _buildScanningState(),
                  
                if (_analysisResults != null) ...[
                  _buildScoreDisplay(),
                  const SizedBox(height: 24),
                  _buildSectionChecklist(),
                  const SizedBox(height: 24),
                  _buildFeedbackTabs(),
                  const SizedBox(height: 16),
                  _buildReuploadButton(),
                ],
                
                if (!_isAnalyzing && _analysisResults == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _buildActionButton(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFairnessBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_rounded, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ethical AI Enabled: We strip personal data to ensure your score is based purely on merit and skills.',
              style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadZone() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 2),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.upload_file_rounded, size: 50, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 20),
            const Text('Upload Your CV / Resume', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Supports PDF & DOCX (Max 5MB)', 
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.description_rounded, size: 40, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_pickedFile!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB', 
                    style: TextStyle(color: Colors.grey.shade600)
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() { _pickedFile = null; }),
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _scanningProgress,
                  strokeWidth: 10,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
                Text('${(_scanningProgress * 100).toInt()}%', 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(_scanningStep, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey)
          ),
          const SizedBox(height: 8),
          const Text('Analyzing for JustScreen compliance...', 
            style: TextStyle(fontSize: 12, color: Colors.grey)
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    final int score = (_analysisResults?['resume_score'] as num? ?? 0).toInt();
    Color scoreColor;
    String statusText;
    
    if (score >= 80) {
      scoreColor = Colors.green;
      statusText = 'STRONG';
    } else if (score >= 50) {
      scoreColor = Colors.orange;
      statusText = 'AVERAGE';
    } else {
      scoreColor = Colors.red;
      statusText = 'WEAK';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
        border: Border.all(color: scoreColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text('Your Resume Check Score', 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Stack(
                alignment: Alignment.center,
                children: [
                   SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 12,
                      backgroundColor: scoreColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  Text('$score', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: scoreColor)),
                ],
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusText, style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      color: scoreColor
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('RESUME STRENGTH', 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: scoreColor)
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _analysisResults?['ats_feedback'] ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.blueGrey.shade700, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionChecklist() {
    final sections = (list: _analysisResults?['sections_found'] as List<dynamic>? ?? []);
    final List<String> required = ['education', 'experience', 'skills', 'projects', 'certifications'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Critical Sections Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: required.length,
          itemBuilder: (context, index) {
            final section = required[index];
            final bool found = sections.list.map((e) => e.toString().toLowerCase()).contains(section);
            return _buildSectionItem(section.toUpperCase(), found);
          },
        ),
      ],
    );
  }

  Widget _buildSectionItem(String label, bool found) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: found ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: found ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(found ? Icons.check_circle_rounded : Icons.cancel_rounded, 
            size: 18, color: found ? Colors.green : Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildFeedbackTabs() {
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(child: Text('ANALYSIS & FEEDBACK', style: TextStyle(fontWeight: FontWeight.bold))),
                Tab(child: Text('DETECTED SKILLS', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFeedbackList(),
                  _buildSkillsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackList() {
    final strengths = _analysisResults?['strengths'] as List<dynamic>? ?? [];
    final weaknesses = _analysisResults?['weaknesses'] as List<dynamic>? ?? [];
    final suggestions = _analysisResults?['suggestions'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (strengths.isNotEmpty) _buildFeedbackGroup('Key Strengths', strengths, Colors.green, Icons.check),
        if (weaknesses.isNotEmpty) _buildFeedbackGroup('Areas for Improvement', weaknesses, Colors.redAccent, Icons.close),
        if (suggestions.isNotEmpty) _buildFeedbackGroup('Actionable Suggestions', suggestions, Colors.blue, Icons.lightbulb_outline),
      ],
    );
  }

  Widget _buildFeedbackGroup(String title, List<dynamic> items, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title.toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.1)),
        ),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 10),
              Expanded(child: Text(item.toString(), style: const TextStyle(fontSize: 14))),
            ],
          ),
        )),
        const Divider(),
      ],
    );
  }

  Widget _buildSkillsList() {
    final skills = _analysisResults?['skills_detected'] as List<dynamic>? ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: skills.isEmpty 
        ? const Center(child: Text('No relevant skills found.'))
        : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) => Chip(
              label: Text(s.toString(), style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.blue.withOpacity(0.05),
              side: BorderSide(color: Colors.blue.withOpacity(0.2)),
            )).toList(),
          ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _pickedFile == null ? null : _analyzeResume,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: const Color(0xFF1A237E).withOpacity(0.4),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_fix_high_rounded),
          SizedBox(width: 12),
          Text('SCAN & ANALYZE NOW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildReuploadButton() {
    return TextButton.icon(
      onPressed: () => setState(() { _pickedFile = null; _analysisResults = null; }),
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('SCAN ANOTHER RESUME'),
    );
  }
}
