import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SkillQuizService {
  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  static const String baseUrl = 'http://192.168.10.6:8000';
  
  /// Generate quiz questions for a specific skill
  Future<Map<String, dynamic>> generateQuiz(String skill) async {
    try {
      debugPrint('Generating quiz for skill: $skill');
      
      final response = await http.post(
        Uri.parse('$baseUrl/generate-quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'skill': skill,
          'num_questions': 10,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please check your connection.');
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Quiz generated successfully: ${data['total_questions']} questions');
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to generate quiz');
      }
    } catch (e) {
      debugPrint('Error generating quiz: $e');
      rethrow;
    }
  }
}
