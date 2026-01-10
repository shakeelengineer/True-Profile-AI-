import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../../../core/constants/api_constants.dart';

class IdentityService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Unified Base URL from ApiConstants
  final String _baseUrl = ApiConstants.baseUrl;

  /// Fetches reference images from Supabase, captures selfie, and verifies.
  Future<Map<String, dynamic>> verifyFace(String selfiePath) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // 1. Fetch reference image URLs (Get the LATEST result)
      final response = await _supabase
          .from('verification_results')
          .select('data')
          .eq('user_id', user.id)
          .eq('verification_type', 'identity')
          .order('updated_at', ascending: false) // Get newest first
          .limit(1)
          .maybeSingle();

      if (response == null || response['data'] == null || response['data']['image_urls'] == null) {
        throw Exception('No reference images found. Please complete identity setup.');
      }

      List<String> imageUrls = List<String>.from(response['data']['image_urls']);
      List<File> referenceFiles = [];

      // 2. Download reference images to temporary storage
      final tempDir = await getTemporaryDirectory();
      for (int i = 0; i < imageUrls.length; i++) {
        final url = imageUrls[i];
        print('Downloading reference ($i/${imageUrls.length}): $url');
        
        try {
          // Attempt 1: Authenticated Supabase Download
          try {
            String relativePath = url.split('/identity/').last;
            final List<int> bytes = await _supabase.storage
                .from('identity')
                .download(relativePath)
                .timeout(const Duration(seconds: 15));
            
            final file = File(path.join(tempDir.path, 'ref_$i.jpg'));
            await file.writeAsBytes(bytes);
            referenceFiles.add(file);
            print('Successfully downloaded via Supabase: $relativePath');
          } catch (e) {
            print('Supabase download failed for $url: $e');
            // Attempt 2: Public HTTP Download
            final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
            if (res.statusCode == 200) {
              final file = File(path.join(tempDir.path, 'ref_$i.jpg'));
              await file.writeAsBytes(res.bodyBytes);
              referenceFiles.add(file);
              print('Successfully downloaded via HTTP: $url');
            } else {
              print('HTTP download failed with status: ${res.statusCode}');
            }
          }
        } catch (e) {
          print('Failed all download attempts for $url: $e');
        }
      }

      if (referenceFiles.isEmpty) {
        throw Exception('Failed to download reference images.');
      }

      // 3. Prepare Multipart Request
      print('Sending verification request to $_baseUrl/verify-face');
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/verify-face'));
      
      request.files.add(await http.MultipartFile.fromPath('selfie', selfiePath, contentType: MediaType('image', 'jpeg')));

      for (var file in referenceFiles) {
        request.files.add(await http.MultipartFile.fromPath('references', file.path, contentType: MediaType('image', 'jpeg')));
      }

      // 4. Send Request
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final apiResponse = await http.Response.fromStream(streamedResponse);

      if (apiResponse.statusCode != 200) {
        throw Exception('API Server Error: ${apiResponse.body}');
      }

      final result = jsonDecode(apiResponse.body);
      
      // 5. If verified, update Profile DP in User Metadata AND status in DB
      if (result['verified'] == true) {
        await _updateProfilePicture(user.id, selfiePath);
        
        // Update DB status so Dashboard reflects 'Verified'
        await _supabase.from('verification_results').update({
          'status': 'completed',
          'score': 100,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', user.id).eq('verification_type', 'identity').eq('status', 'pending');
        
        print('Verification status updated to completed in database.');
      }

      return result;
    } catch (e) {
      print('IdentityService Error: $e');
      return {'verified': false, 'error': e.toString()};
    }
  }

  Future<void> _updateProfilePicture(String userId, String localPath) async {
    try {
      final fileName = '$userId/profile_dp_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(localPath);

      // Upload to 'identity' bucket (Since we know this bucket exists)
      await _supabase.storage.from('identity').upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = _supabase.storage.from('identity').getPublicUrl(fileName);
      print('New Avatar URL: $publicUrl');

      // Update User Metadata
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'avatar_url': publicUrl,
          },
        ),
      );
      await _supabase.auth.refreshSession();
      print('Profile picture updated successfully in metadata and session refreshed.');
    } catch (e) {
      print('Error updating profile picture: $e');
      // Even if metadata update fails, we already have the result verified
    }
  }
}
