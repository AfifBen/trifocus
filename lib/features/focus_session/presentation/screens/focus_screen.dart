import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../goals/presentation/controllers/today_goals_controller.dart';
import '../controllers/active_goal_controller.dart';
import '../controllers/focus_timer_controller.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(focusTimerProvider);
    final notifier = ref.read(focusTimerProvider.notifier);
    final goals = ref.watch(todayGoalsProvider);
    final activeGoalId = ref.watch(activeGoalProvider);

    final effectiveActiveGoalId = activeGoalId ?? (goals.isNotEmpty ? goals.first.id : null);
    if (effectiveActiveGoalId != activeGoalId && goals.isNotEmpty) {
      Future.microtask(() {
        ref.read(activeGoalProvider.notifier).select(effectiveActiveGoalId);
      });
    }

    if (timer.remainingSeconds == 0) {
      Future.microtask(() {
        if (context.mounted) {
          notifier.pause();
          context.go('/break');
        }
      });
    }

    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Focus', style: AppTextStyles.headline),
            const SizedBox(height: 12),
            if (goals.isEmpty)
              const Text('No goals yet. Create your 3 objectives first.', style: AppTextStyles.body)
            else
              DropdownButtonFormField<String>(
                value: effectiveActiveGoalId,
                dropdownColor: AppColors.surface,
                decoration: InputDecoration(
                  hintText: 'Active goal',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                items: goals
                    .map(
                      (g) => DropdownMenuItem<String>(
                        value: g.id,
                        child: Text(g.title, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (id) => ref.read(activeGoalProvider.notifier).select(id),
              ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: timer.progress,
                        strokeWidth: 10,
                        backgroundColor: AppColors.surfaceAlt,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                      Text(
                        _format(timer.remainingSeconds),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: notifier.pause,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Pause'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: notifier.start,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(timer.isRunning ? 'Resume' : 'Start'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  notifier.reset();
                  context.go('/session-complete');
                },
                child: const Text('End Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }
}
