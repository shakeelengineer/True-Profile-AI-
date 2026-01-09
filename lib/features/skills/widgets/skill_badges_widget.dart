import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SkillBadgesWidget extends StatefulWidget {
  const SkillBadgesWidget({super.key});

  @override
  State<SkillBadgesWidget> createState() => _SkillBadgesWidgetState();
}

class _SkillBadgesWidgetState extends State<SkillBadgesWidget> {
  List<Map<String, dynamic>> _badges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('skill_badges')
            .select()
            .eq('user_id', user.id)
            .order('earned_at', ascending: false);

        if (mounted) {
          setState(() {
            _badges = List<Map<String, dynamic>>.from(response);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading badges: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getBadgeColor(int score) {
    if (score >= 95) return Colors.amber; // Gold
    if (score >= 90) return Colors.blueGrey[300]!; // Silver
    return Colors.green; // Bronze/Standard
  }

  IconData _getBadgeIcon(int score) {
    if (score >= 95) return Icons.emoji_events;
    if (score >= 90) return Icons.military_tech;
    return Icons.verified;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: theme.primaryColor),
        ),
      );
    }

    if (_badges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No Badges Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete skill assessments to earn verified badges',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Icon(Icons.workspace_premium, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Verified Skills (${_badges.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: theme.primaryColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _badges.map((badge) {
            final skillName = badge['skill_name'] ?? 'Unknown';
            final score = badge['score'] ?? 0;
            final badgeColor = _getBadgeColor(score);
            final badgeIcon = _getBadgeIcon(score);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    badgeColor.withOpacity(0.2),
                    badgeColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: badgeColor.withOpacity(0.5), width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badgeIcon, color: badgeColor, size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        skillName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '$score%',
                        style: TextStyle(
                          fontSize: 12,
                          color: badgeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
