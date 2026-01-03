import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResumeService {
  final _supabase = Supabase.instance.client;

  // 1. Upload Resume to Supabase Storage
  Future<String?> uploadResume(String userId, File file) async {
    try {
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}_resume.pdf';
      await _supabase.storage.from('resumes').upload(fileName, file);
      
      final publicUrl = _supabase.storage.from('resumes').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Error uploading resume: $e');
      return null;
    }
  }

  // 2. Call Python ATS API (Local Host)
  Future<Map<String, dynamic>?> analyzeResume(File file) async {
    try {
      // For Physical Device: Use your PC's LAN IP (e.g., 192.168.10.5)
      // For Emulator: Use 10.0.2.2
      const String backendUrl = 'http://192.168.10.4:8000/analyze-resume';
      
      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      // Add optional check for emulator fallback if needed
      // ...
      
      print('Sending resume to $backendUrl');
      var response = await request.send();
      
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        return json.decode(respStr);
      } else {
        print('Backend error: ${response.statusCode}');
        // Fallback or better error handling
        return null;
      }
    } catch (e) {
      print('Error calling ATS API: $e');
      return null;
    }
  }

  // 3. Save results to Supabase DB
  Future<void> saveAnalysisResult({
    required String userId,
    required int score,
    required List<dynamic> skills,
    required List<dynamic> strengths,
    required List<dynamic> weaknesses,
    required List<dynamic> suggestions,
    required String feedback,
  }) async {
    try {
      await _supabase.from('verification_results').insert({
        'user_id': userId,
        'verification_type': 'resume',
        'status': 'completed',
        'score': score,
        'data': {
          'skills': skills,
          'strengths': strengths,
          'weaknesses': weaknesses,
          'suggestions': suggestions,
        },
        'feedback': [feedback],
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving results: $e');
    }
  }
}
