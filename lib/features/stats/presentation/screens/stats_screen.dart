import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stats', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            const Text('Your focus performance', style: AppTextStyles.body),
            const SizedBox(height: 24),
            _StatCard(title: 'Sessions this week', value: '12'),
            const SizedBox(height: 12),
            _StatCard(title: 'Focus hours', value: '6h 30m'),
            const SizedBox(height: 12),
            _StatCard(title: 'Completion rate', value: '84%'),
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
