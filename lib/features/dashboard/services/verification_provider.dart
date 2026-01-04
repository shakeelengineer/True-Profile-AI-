import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationStatus {
  final bool identityVerified;
  final bool resumeVerified;
  final bool skillsVerified;
  final String identityStatus;
  final String resumeStatus;
  final String skillsStatus;
  final int completedCount;
  final double progress;

  VerificationStatus({
    required this.identityVerified,
    required this.resumeVerified,
    required this.skillsVerified,
    required this.identityStatus,
    required this.resumeStatus,
    required this.skillsStatus,
    required this.completedCount,
    required this.progress,
  });

  factory VerificationStatus.initial() {
    return VerificationStatus(
      identityVerified: false,
      resumeVerified: false,
      skillsVerified: false,
      identityStatus: 'not_started',
      resumeStatus: 'not_started',
      skillsStatus: 'not_started',
      completedCount: 0,
      progress: 0.0,
    );
  }

  static String getStatusLabel(String? status) {
    switch (status) {
      case 'completed': return 'Completed';
      case 'pending': return 'In Progress';
      case 'failed': return 'Action Required';
      default: return 'Not Started';
    }
  }

  static Color getStatusColor(String? status, ThemeData theme) {
    switch (status) {
      case 'completed': return const Color(0xFF10B981);
      case 'pending': return const Color(0xFFFDB241);
      case 'failed': return Colors.redAccent;
      default: return theme.colorScheme.onSurface.withOpacity(0.3);
    }
  }
}

final verificationProvider = StreamProvider<VerificationStatus>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    return Stream.value(VerificationStatus.initial());
  }

  return Supabase.instance.client
      .from('verification_results')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .map((results) {
        String idStatus = 'not_started';
        String resStatus = 'not_started';
        String skStatus = 'not_started';

        // Sort results by updated_at descending to get the latest status for each type
        final sortedResults = List<Map<String, dynamic>>.from(results)
          ..sort((a, b) => b['updated_at'].compareTo(a['updated_at']));

        for (var result in sortedResults) {
          final type = result['verification_type'];
          final status = result['status'];
          
          if (type == 'identity' && idStatus == 'not_started') idStatus = status;
          if (type == 'resume' && resStatus == 'not_started') resStatus = status;
          if (type == 'skills' && skStatus == 'not_started') skStatus = status;
        }

        int count = 0;
        if (idStatus == 'completed') count++;
        if (resStatus == 'completed') count++;
        if (skStatus == 'completed') count++;

        // Progress includes pending items too
        double progressVal = 0;
        if (idStatus != 'not_started') progressVal += 0.33;
        if (resStatus != 'not_started') progressVal += 0.33;
        if (skStatus != 'not_started') progressVal += 0.34;

        return VerificationStatus(
          identityVerified: idStatus == 'completed',
          resumeVerified: resStatus == 'completed',
          skillsVerified: skStatus == 'completed',
          identityStatus: idStatus,
          resumeStatus: resStatus,
          skillsStatus: skStatus,
          completedCount: count,
          progress: progressVal,
        );
      });
});
final verificationHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    return Stream.value([]);
  }

  return Supabase.instance.client
      .from('verification_results')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .order('updated_at', ascending: false);
});
