import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../dashboard/services/verification_provider.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(verificationHistoryProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('History & Integrity', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            indicatorWeight: 3,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.4),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            tabs: const [
              Tab(text: 'IDENTITY'),
              Tab(text: 'RESUME'),
              Tab(text: 'SKILLS'),
            ],
          ),
        ),
        body: historyAsync.when(
          data: (history) => TabBarView(
            children: [
              _buildHistoryList(theme, history, 'identity'),
              _buildHistoryList(theme, history, 'resume'),
              _buildHistoryList(theme, history, 'skills'),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading results: $e')),
        ),
      ),
    );
  }

  Widget _buildHistoryList(ThemeData theme, List<Map<String, dynamic>> history, String type) {
    final filtered = history.where((item) => item['verification_type'] == type).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(theme, 'No records found.', 'Start your first $type check to see history.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final DateTime date = DateTime.parse(item['updated_at']);
        final status = item['status'];
        final score = item['score'] ?? 0;
        final feedbackList = (item['feedback'] as List<dynamic>?) ?? [];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildResultCard(
            theme: theme,
            title: _getDisplayTitle(type),
            date: DateFormat('MMM dd, yyyy • HH:mm').format(date),
            status: status.toString().toUpperCase(),
            statusColor: _getStatusColor(status, theme),
            icon: _getTypeIcon(type),
            score: score,
            feedback: feedbackList.isNotEmpty ? feedbackList.first.toString() : 'No feedback available.',
            type: type,
            details: item['data'] ?? {},
          ),
        );
      },
    );
  }

  String _getDisplayTitle(String type) {
    switch (type) {
      case 'identity': return 'Biometric Synthesis';
      case 'resume': return 'ATS Merit Scan';
      case 'skills': return 'Domain expertise';
      default: return 'Verification';
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'identity': return Icons.verified_user_rounded;
      case 'resume': return Icons.description_rounded;
      case 'skills': return Icons.psychology_rounded;
      default: return Icons.check_circle_rounded;
    }
  }

  Color _getStatusColor(dynamic status, ThemeData theme) {
    switch (status) {
      case 'completed': return const Color(0xFF10B981);
      case 'pending': return const Color(0xFFFDB241);
      case 'failed': return Colors.redAccent;
      default: return theme.primaryColor;
    }
  }

  Widget _buildEmptyState(ThemeData theme, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required ThemeData theme,
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required IconData icon,
    required int score,
    required String feedback,
    required String type,
    required Map<String, dynamic> details,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(date, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (type != 'identity') ...[
            Row(
              children: [
                Text('SCORE: ', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold)),
                Text('$score%', style: TextStyle(color: statusColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI FEEDBACK', style: TextStyle(color: theme.primaryColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 8),
                Text(feedback, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 13, height: 1.5)),
                if (type == 'skills' && details.containsKey('skills_verified')) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (details['skills_verified'] as List<dynamic>).map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(s.toString(), style: TextStyle(color: theme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
