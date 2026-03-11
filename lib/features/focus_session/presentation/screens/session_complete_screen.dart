import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../stats/presentation/controllers/stats_controller.dart';
import '../../../goals/presentation/controllers/today_goals_controller.dart';
import '../../../history/domain/models/focus_log.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../controllers/active_goal_controller.dart';
import '../controllers/focus_timer_controller.dart';

class SessionCompleteScreen extends ConsumerStatefulWidget {
  const SessionCompleteScreen({super.key});

  @override
  ConsumerState<SessionCompleteScreen> createState() => _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends ConsumerState<SessionCompleteScreen> {
  bool _counted = false;
  bool _goalUpdated = false;
  bool _logged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_counted) {
      _counted = true;
      ref.read(statsProvider.notifier).completeSession();
    }
    if (!_goalUpdated) {
      _goalUpdated = true;
      _incrementActiveGoal();
    }
    if (!_logged) {
      _logged = true;
      _logSession();
    }
  }

  Future<void> _logSession() async {
    final goalId = ref.read(activeGoalProvider);
    final goals = ref.read(todayGoalsProvider);

    String? title;
    if (goals.isNotEmpty) {
      final idx = goalId == null ? 0 : goals.indexWhere((g) => g.id == goalId);
      final safeIdx = idx >= 0 ? idx : 0;
      title = goals[safeIdx].title;
    }

    final focusTimer = ref.read(focusTimerProvider);
    final duration = focusTimer.totalSeconds;

    await ref.read(historyProvider.notifier).add(
          FocusLog(
            id: 'log_${DateTime.now().millisecondsSinceEpoch}',
            goalId: goalId,
            goalTitle: title,
            durationSeconds: duration,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> _incrementActiveGoal() async {
    final goalId = ref.read(activeGoalProvider);
    if (goalId == null) return;

    final goals = ref.read(todayGoalsProvider);
    final idx = goals.indexWhere((g) => g.id == goalId);
    if (idx == -1) return;

    final goal = goals[idx];
    final updated = goal.copyWith(
      sessionsDone: (goal.sessionsDone + 1).clamp(0, goal.sessionsTotal),
    );
    await ref.read(todayGoalsProvider.notifier).updateGoal(updated);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Session Complete', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            const Text('Nice work. Keep the momentum.', style: AppTextStyles.body),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle, size: 64, color: AppColors.success),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/today'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Back to Today'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
