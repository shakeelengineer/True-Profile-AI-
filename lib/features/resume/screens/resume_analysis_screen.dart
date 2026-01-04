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
      _scanningProgress = 0.1;
      _scanningStep = 'Initializing JustScreen AI...';
      _analysisResults = null;
    });

    try {
      final file = File(_pickedFile!.path!);
      
      if (mounted) {
        setState(() {
          _scanningStep = 'Uploading Document...';
          _scanningProgress = 0.3;
        });
      }

      final apiResult = await _resumeService.analyzeResume(
        file,
        onProgress: (p) {
          if (mounted) {
            setState(() {
              // Map 0-1.0 to 0.3 -> 0.7
              _scanningProgress = 0.3 + (p * 0.4);
              if (p >= 1.0) {
                _scanningStep = 'AI is processing your resume... (Step 1/2)';
              }
            });
          }
        },
      );

      // If we got here, it's done or processing fast
      if (mounted) {
        setState(() {
          _scanningStep = 'Finalizing AI Insights... (Step 2/2)';
          _scanningProgress = 0.9;
        });
      }

      if (apiResult != null && mounted) {
        setState(() {
          _scanningProgress = 1.0;
          _analysisResults = apiResult;
          _isAnalyzing = false;
        });

        final user = Supabase.instance.client.auth.currentUser;
        if (user != null && apiResult['resume_score'] != null) {
          try {
            await _resumeService.uploadResume(user.id, file);
            await _resumeService.saveAnalysisResult(
              userId: user.id,
              score: (apiResult['resume_score'] as num).toInt(),
              skills: apiResult['skills_detected'] ?? [],
              strengths: apiResult['strengths'] ?? [],
              weaknesses: apiResult['weaknesses'] ?? [],
              suggestions: apiResult['suggestions'] ?? [],
              feedback: apiResult['ats_feedback'] ?? '',
            );
          } catch (e) {
            print('Post-analysis storage error: $e');
          }
        }
      } else {
        throw 'The AI engine returned an empty response.';
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _scanningProgress = 0.0;
        });
        
        String errorMsg = e.toString();
        // Clean up common error strings for user
        if (errorMsg.contains('Exception:')) {
          errorMsg = errorMsg.split('Exception:').last.trim();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(label: 'Retry', textColor: Colors.white, onPressed: _analyzeResume),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_outlined,
                color: theme.scaffoldBackgroundColor,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Text('JustScreen AI', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFairnessBanner(theme),
                const SizedBox(height: 24),
                if (_pickedFile != null && !_isAnalyzing && _analysisResults == null) 
                  _buildFilePreview(theme)
                else if (_analysisResults == null && !_isAnalyzing)
                  _buildUploadZone(theme),
                
                if (_isAnalyzing)
                  _buildScanningState(theme),
                  
                if (_analysisResults != null) ...[
                  _buildScoreDisplay(theme),
                  const SizedBox(height: 24),
                  _buildSectionChecklist(theme),
                  const SizedBox(height: 24),
                  _buildFeedbackTabs(theme),
                  const SizedBox(height: 16),
                  _buildReuploadButton(theme),
                ],
                
                if (!_isAnalyzing && _analysisResults == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _buildActionButton(theme),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFairnessBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_rounded, color: theme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ethical AI Enabled: We strip personal data to ensure your score is based purely on merit and skills.',
              style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadZone(ThemeData theme) {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.primaryColor.withOpacity(0.2), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.upload_file_rounded, size: 50, color: theme.primaryColor),
            ),
            const SizedBox(height: 20),
            const Text('Upload Your CV / Resume', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Supports PDF & DOCX (Max 5MB)', 
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.description_rounded, size: 40, color: theme.primaryColor.withOpacity(0.7)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_pickedFile!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB', 
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))
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

  Widget _buildScanningState(ThemeData theme) {
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
                  strokeWidth: 8,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
                Text('${(_scanningProgress * 100).toInt()}%', 
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(_scanningStep, 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: theme.primaryColor)
          ),
          const SizedBox(height: 8),
          Text('Analyzing for JustScreen compliance...', 
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(ThemeData theme) {
    final int score = (_analysisResults?['resume_score'] as num? ?? 0).toInt();
    Color scoreColor;
    String statusText;
    
    if (score >= 80) {
      scoreColor = const Color(0xFF10B981); // Emerald
      statusText = 'STRONG';
    } else if (score >= 50) {
      scoreColor = const Color(0xFFF59E0B); // Amber
      statusText = 'AVERAGE';
    } else {
      scoreColor = const Color(0xFFEF4444); // Red
      statusText = 'WEAK';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: scoreColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          Text('ATS Compatibility Score', 
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.6), letterSpacing: 1.2)
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Stack(
                alignment: Alignment.center,
                children: [
                   SizedBox(
                    height: 110,
                    width: 110,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 10,
                      backgroundColor: scoreColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  Text('$score', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: scoreColor)),
                ],
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusText, style: TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: scoreColor
                    )),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('PROFILE RATING', 
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: scoreColor)
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
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.8), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionChecklist(ThemeData theme) {
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
            childAspectRatio: 3.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: required.length,
          itemBuilder: (context, index) {
            final section = required[index];
            final bool found = sections.list.map((e) => e.toString().toLowerCase()).contains(section);
            return _buildSectionItem(theme, section.toUpperCase(), found);
          },
        ),
      ],
    );
  }

  Widget _buildSectionItem(ThemeData theme, String label, bool found) {
    final color = found ? theme.primaryColor : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(found ? Icons.check_circle_rounded : Icons.cancel_rounded, 
            size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildFeedbackTabs(ThemeData theme) {
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: theme.primaryColor,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.5),
              indicatorColor: theme.primaryColor,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(child: Text('FEEDBACK', style: TextStyle(fontWeight: FontWeight.bold))),
                Tab(child: Text('SKILLS', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFeedbackList(theme),
                  _buildSkillsList(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackList(ThemeData theme) {
    final strengths = _analysisResults?['strengths'] as List<dynamic>? ?? [];
    final weaknesses = _analysisResults?['weaknesses'] as List<dynamic>? ?? [];
    final suggestions = _analysisResults?['suggestions'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (strengths.isNotEmpty) _buildFeedbackGroup(theme, 'Key Strengths', strengths, theme.primaryColor, Icons.verified_rounded),
        if (weaknesses.isNotEmpty) _buildFeedbackGroup(theme, 'Improvements', weaknesses, Colors.orangeAccent, Icons.trending_up_rounded),
        if (suggestions.isNotEmpty) _buildFeedbackGroup(theme, 'Action Plan', suggestions, theme.colorScheme.secondary, Icons.lightbulb_outline),
      ],
    );
  }

  Widget _buildFeedbackGroup(ThemeData theme, String title, List<dynamic> items, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.1)),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 26),
          child: Text('• ${item.toString()}', 
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.8))
          ),
        )),
        const SizedBox(height: 8),
        Divider(color: theme.colorScheme.outline.withOpacity(0.2)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSkillsList(ThemeData theme) {
    final skills = _analysisResults?['skills_detected'] as List<dynamic>? ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: skills.isEmpty 
        ? Center(child: Text('No relevant skills found.', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))))
        : Wrap(
            spacing: 10,
            runSpacing: 10,
            children: skills.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
              ),
              child: Text(s.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.primaryColor)),
            )).toList(),
          ),
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: _pickedFile == null ? null : _analyzeResume,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_fix_high_rounded),
          SizedBox(width: 12),
          Text('SCAN & ANALYZE NOW'),
        ],
      ),
    );
  }

  Widget _buildReuploadButton(ThemeData theme) {
    return TextButton.icon(
      onPressed: () => setState(() { _pickedFile = null; _analysisResults = null; }),
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('SCAN ANOTHER RESUME'),
      style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
    );
  }
}
