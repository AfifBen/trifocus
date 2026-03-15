import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../goals/presentation/controllers/today_goals_controller.dart';
import '../../../history/domain/models/focus_log.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../stats/presentation/controllers/stats_controller.dart';
import '../controllers/active_goal_controller.dart';

final sessionFinalizeProvider = Provider<SessionFinalizeController>(
  (ref) => SessionFinalizeController(ref),
);

class SessionFinalizeController {
  final Ref _ref;
  SessionFinalizeController(this._ref);

  Future<void> finalize({
    required FocusLogStatus status,
    required int durationSeconds,
    required int plannedDurationSeconds,
  }) async {
    // 1) Stats/streak
    await _ref.read(statsProvider.notifier).completeSession();

    // 2) Increment goal sessionsDone
    final goalId = _ref.read(activeGoalProvider);
    if (goalId != null) {
      final goals = _ref.read(todayGoalsProvider);
      final idx = goals.indexWhere((g) => g.id == goalId);
      if (idx >= 0) {
        final goal = goals[idx];
        final updated = goal.copyWith(
          sessionsDone: (goal.sessionsDone + 1).clamp(0, goal.sessionsTotal),
        );
        await _ref.read(todayGoalsProvider.notifier).updateGoal(updated);
      }
    }

    // 3) History log
    final goals = _ref.read(todayGoalsProvider);
    String? title;
    if (goals.isNotEmpty) {
      final idx = goalId == null ? 0 : goals.indexWhere((g) => g.id == goalId);
      final safeIdx = idx >= 0 ? idx : 0;
      title = goals[safeIdx].title;
    }

    await _ref.read(historyProvider.notifier).add(
          FocusLog(
            id: 'log_${DateTime.now().microsecondsSinceEpoch}',
            goalId: goalId,
            goalTitle: title,
            durationSeconds: durationSeconds,
            plannedDurationSeconds: plannedDurationSeconds,
            createdAt: DateTime.now(),
            status: status,
          ),
        );
  }
}
