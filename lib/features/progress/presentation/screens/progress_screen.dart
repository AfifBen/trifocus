import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../controllers/progress_world_controller.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = ref.watch(progressWorldProvider);

    final stageProgress =
        world.xpForNextStage == 0 ? 0.0 : world.xpIntoStage / world.xpForNextStage;

    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Progress', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            const Text('Your world grows as you focus.', style: AppTextStyles.body),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Stage ${world.stageIndex}', style: AppTextStyles.body),
                        const SizedBox(height: 6),
                        Text(world.stageName, style: AppTextStyles.headline),
                        const SizedBox(height: 10),
                        Text('Level ${world.level}', style: AppTextStyles.title),
                        const SizedBox(height: 10),
                        Text('${world.totalXp} XP', style: AppTextStyles.body),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: stageProgress.clamp(0, 1),
                backgroundColor: AppColors.surfaceAlt,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${world.xpIntoStage}/${world.xpForNextStage} XP to next stage',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            _StatRow(label: 'Completed sessions', value: '${world.completedSessions}'),
            const SizedBox(height: 8),
            _StatRow(label: 'Streak multiplier', value: 'x${world.streakMultiplier.toStringAsFixed(1)}'),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

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
          Text(label, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.title),
        ],
      ),
    );
  }
}
