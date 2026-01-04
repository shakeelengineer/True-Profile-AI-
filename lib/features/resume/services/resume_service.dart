import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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

  // 2. Call Python ATS API (Optimized & More Resilient)
  Future<Map<String, dynamic>?> analyzeResume(
    File file, 
    {required Function(double) onProgress}
  ) async {
    try {
      // PRO TIP: Change this IP to your PC's current LAN IP if testing on a physical device
      const String backendUrl = 'http://192.168.10.4:8000/analyze-resume';
      
      final request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      
      final bytes = await file.readAsBytes();
      final totalByteCount = bytes.length;
      
      // Use a simple split for filename to avoid Platform issues on mobile
      final fileName = file.path.contains('/') 
          ? file.path.split('/').last 
          : file.path.split('\\').last;

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      );
      
      request.files.add(multipartFile);
      
      // Immediate progress jump to indicate upload start
      onProgress(0.5);
      
      print('Sending resume to $backendUrl (${(totalByteCount/1024).toStringAsFixed(2)} KB)...');
      
      // Increased timeout to 60s because local AI models (like LLMs or heavy NLP) can be slow
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('Request to $backendUrl timed out after 60 seconds.');
          throw TimeoutException('JustScreen AI server is unreachable or taking too long to process.');
        },
      );
      
      onProgress(1.0);
      
      final response = await http.Response.fromStream(streamedResponse);
      print('Backend Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw 'Server error (${response.statusCode}): ${response.body}';
      }
    } on SocketException catch (e) {
      print('Socket Error: $e');
      throw 'Connection Refused: Ensure your backend is running at http://192.168.10.4:8000 and firewall is open.';
    } catch (e) {
      print('Critical Error in analyzeResume: $e');
      rethrow;
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
