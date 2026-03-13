import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../history/domain/models/focus_log.dart';
import '../../../history/presentation/controllers/history_controller.dart';

class AnalyticsState {
  final Map<String, int> minutesByDay; // yyyy-mm-dd -> minutes
  final List<MapEntry<String, int>> topGoals; // goalTitle -> minutes

  const AnalyticsState({
    required this.minutesByDay,
    required this.topGoals,
  });
}

final analyticsProvider = Provider<AnalyticsState>((ref) {
  final logs = ref.watch(historyProvider);
  final completed = logs.where((l) => l.status == FocusLogStatus.completed);

  String dayKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  final byDay = <String, int>{};
  final byGoal = <String, int>{};

  for (final l in completed) {
    final key = dayKey(l.createdAt);
    byDay[key] = (byDay[key] ?? 0) + (l.durationSeconds ~/ 60);

    final goal = (l.goalTitle ?? 'Focus session').trim();
    byGoal[goal] = (byGoal[goal] ?? 0) + (l.durationSeconds ~/ 60);
  }

  final top = byGoal.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return AnalyticsState(
    minutesByDay: byDay,
    topGoals: top.take(5).toList(),
  );
});
