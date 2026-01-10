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
  final int badgeCount;
  final double progress;

  VerificationStatus({
    required this.identityVerified,
    required this.resumeVerified,
    required this.skillsVerified,
    required this.identityStatus,
    required this.resumeStatus,
    required this.skillsStatus,
    required this.completedCount,
    required this.badgeCount,
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
      badgeCount: 0,
      progress: 0.0,
    );
  }

  static String getStatusLabel(String? status) {
    switch (status) {
      case 'completed': return 'Completed';
      case 'verified': return 'Verified';
      case 'pending': return 'In Progress';
      case 'failed': return 'Action Required';
      default: return 'Not Started';
    }
  }

  static Color getStatusColor(String? status, ThemeData theme) {
    switch (status) {
      case 'completed': 
      case 'verified': return const Color(0xFF10B981);
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
        // Initialize statuses
        String idStatus = 'not_started';
        String resStatus = 'not_started';
        String skStatus = 'not_started';

        // Sort by updated_at to get the most recent record for each type
        final sorted = List<Map<String, dynamic>>.from(results)
          ..sort((a, b) => b['updated_at'].compareTo(a['updated_at']));

        // Get the SINGLE latest status for each type
        for (var r in sorted) {
          final t = r['verification_type'];
          final s = r['status'];
          if (t == 'identity' && idStatus == 'not_started') idStatus = s;
          if (t == 'resume' && resStatus == 'not_started') resStatus = s;
          if (t == 'skills' && skStatus == 'not_started') skStatus = s;
        }

        // Logic check for successful states
        // Identity and Resume succeed with 'completed' or 'verified'
        final bool isIdDone = idStatus == 'completed' || idStatus == 'verified';
        final bool isResDone = resStatus == 'completed' || resStatus == 'verified';
        
        // Skills ONLY succeed if 'verified' (passed the quiz)
        final bool isSkDone = skStatus == 'verified';

        // Calculate completed count for the stats card
        int completedCount = 0;
        if (isIdDone) completedCount++;
        if (isResDone) completedCount++;
        if (isSkDone) completedCount++;

        // Weighted Progress: Identity(50%) + Resume(25%) + Skills(25%)
        double progressVal = 0.0;
        if (isIdDone) progressVal += 0.50;
        if (isResDone) progressVal += 0.25;
        if (isSkDone) progressVal += 0.25;

        // Final snap to 100%
        if (isIdDone && isResDone && isSkDone) progressVal = 1.0;

        return VerificationStatus(
          identityVerified: isIdDone,
          resumeVerified: isResDone,
          skillsVerified: isSkDone,
          identityStatus: idStatus,
          resumeStatus: resStatus,
          skillsStatus: skStatus,
          completedCount: completedCount,
          badgeCount: completedCount,
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
