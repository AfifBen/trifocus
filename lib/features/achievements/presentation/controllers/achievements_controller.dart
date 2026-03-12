import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../history/domain/models/focus_log.dart';
import '../../../stats/presentation/controllers/stats_controller.dart';
import '../../domain/models/achievement.dart';

final achievementsProvider = Provider<List<Achievement>>((ref) {
  final streak = ref.watch(statsProvider).streakDays;
  final totalSessions = ref
      .watch(historyProvider)
      .where((l) => l.status == FocusLogStatus.completed)
      .length;

  bool unlockedStreak(int days) => streak >= days;
  bool unlockedSessions(int count) => totalSessions >= count;

  return [
    Achievement(
      id: 'streak_3',
      title: '3-day streak',
      description: 'Keep your streak for 3 days',
      unlocked: unlockedStreak(3),
    ),
    Achievement(
      id: 'streak_7',
      title: '7-day streak',
      description: 'Keep your streak for 7 days',
      unlocked: unlockedStreak(7),
    ),
    Achievement(
      id: 'sessions_10',
      title: '10 sessions',
      description: 'Complete 10 focus sessions',
      unlocked: unlockedSessions(10),
    ),
    Achievement(
      id: 'sessions_50',
      title: '50 sessions',
      description: 'Complete 50 focus sessions',
      unlocked: unlockedSessions(50),
    ),
  ];
});
