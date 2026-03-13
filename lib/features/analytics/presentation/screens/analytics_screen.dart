import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final days = _lastNDays(21);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppColors.background,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text('Focus heatmap (21 days)', style: AppTextStyles.title),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: days.map((d) {
                final m = analytics.minutesByDay[d] ?? 0;
                final color = _colorForMinutes(m);
                return Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Top goals', style: AppTextStyles.title),
            const SizedBox(height: 12),
            if (analytics.topGoals.isEmpty)
              const Text('No data yet', style: AppTextStyles.body)
            else
              ...analytics.topGoals.map((e) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          style: AppTextStyles.body,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${e.value} min', style: AppTextStyles.title),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  List<String> _lastNDays(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) {
      final dt = now.subtract(Duration(days: n - 1 - i));
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    });
  }

  Color _colorForMinutes(int minutes) {
    if (minutes <= 0) return AppColors.surfaceAlt;
    if (minutes < 15) return AppColors.primary.withOpacity(0.25);
    if (minutes < 30) return AppColors.primary.withOpacity(0.45);
    if (minutes < 60) return AppColors.primary.withOpacity(0.7);
    return AppColors.primary;
  }
}
