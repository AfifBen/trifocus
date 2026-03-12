import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../controllers/stats_controller.dart';
import '../controllers/stats_derived_controller.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final derived = ref.watch(derivedStatsProvider);

    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Stats', style: AppTextStyles.headline),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.push('/history'),
                      icon: const Icon(Icons.history,
                          color: AppColors.textPrimary),
                    ),
                    IconButton(
                      onPressed: () => context.push('/achievements'),
                      icon: const Icon(Icons.emoji_events,
                          color: AppColors.textPrimary),
                    ),
                    IconButton(
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.settings,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Your focus performance', style: AppTextStyles.body),
            const SizedBox(height: 24),
            _StatCard(
                title: 'Total sessions', value: '${derived.totalSessions}'),
            const SizedBox(height: 12),
            _StatCard(title: 'Focus today', value: '${derived.minutesToday} min'),
            const SizedBox(height: 12),
            _StatCard(
                title: 'Focus this week',
                value: '${derived.minutesThisWeek} min'),
            const SizedBox(height: 12),
            _StatCard(title: 'Streak', value: '${stats.streakDays} days'),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.title),
        ],
      ),
    );
  }
}
