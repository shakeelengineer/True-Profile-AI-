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

  // ===== CONFIGURATION =====
  // Primary: Render.com (Production - Free Tier)
  // Fallback: Local Server (Development)
  static const String _renderUrl = 'https://ats-resume-service.onrender.com'; // Update this after deployment
  static const String _localIp = '192.168.10.6'; // Your local network IP
  static const String _localUrl = 'http://$_localIp:8000';
  
  // Set to false to use local server only (for development)
  static const bool _useRender = true;
  
  // 2. Call Python ATS API (Smart Fallback: Render → Local)
  Future<Map<String, dynamic>?> analyzeResume(
    File file, 
    {required Function(double) onProgress}
  ) async {
    final bytes = await file.readAsBytes();
    final fileName = file.path.contains('/') 
        ? file.path.split('/').last 
        : file.path.split('\\').last;
    
    // Try Render first (if enabled)
    if (_useRender) {
      try {
        print('🌐 Attempting to connect to Render.com...');
        final result = await _sendAnalysisRequest(
          url: '$_renderUrl/analyze-resume',
          bytes: bytes,
          fileName: fileName,
          onProgress: onProgress,
          timeout: Duration(seconds: 120), // Render cold start can take 60s
        );
        
        if (result != null) {
          print('✅ Successfully analyzed via Render.com');
          return result;
        }
      } catch (e) {
        print('⚠️ Render.com failed: $e');
        print('🔄 Falling back to local server...');
      }
    }
    
    // Fallback to local server
    try {
      print('🏠 Attempting to connect to local server at $_localUrl...');
      final result = await _sendAnalysisRequest(
        url: '$_localUrl/analyze-resume',
        bytes: bytes,
        fileName: fileName,
        onProgress: onProgress,
        timeout: Duration(seconds: 90),
      );
      
      if (result != null) {
        print('✅ Successfully analyzed via local server');
        return result;
      }
    } catch (e) {
      print('❌ Local server also failed: $e');
      throw 'Unable to connect to ATS service.\n\n'
          '• Render: ${_useRender ? "Failed" : "Disabled"}\n'
          '• Local: Failed\n\n'
          'Please ensure your local Python server is running:\n'
          'python main.py in backend/ats_service';
    }
    
    throw 'Both Render and local servers are unavailable';
  }
  
  // Helper method to send analysis request
  Future<Map<String, dynamic>?> _sendAnalysisRequest({
    required String url,
    required List<int> bytes,
    required String fileName,
    required Function(double) onProgress,
    required Duration timeout,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
    );
    
    request.files.add(multipartFile);
    onProgress(0.5);
    
    print('📤 Sending resume to $url (${(bytes.length/1024).toStringAsFixed(2)} KB)...');
    
    final streamedResponse = await request.send().timeout(
      timeout,
      onTimeout: () {
        throw TimeoutException('Request to $url timed out after ${timeout.inSeconds}s');
      },
    );
    
    onProgress(0.8);
    
    final response = await http.Response.fromStream(streamedResponse);
    print('📥 Response Code: ${response.statusCode}');
    
    onProgress(1.0);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw 'Server error (${response.statusCode}): ${response.body}';
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
