import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../history/presentation/controllers/history_controller.dart';

class DerivedStats {
  final int totalSessions;
  final int minutesToday;
  final int minutesThisWeek;

  const DerivedStats({
    required this.totalSessions,
    required this.minutesToday,
    required this.minutesThisWeek,
  });
}

final derivedStatsProvider = Provider<DerivedStats>((ref) {
  final logs = ref.watch(historyProvider);
  final now = DateTime.now();

  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  final todayMinutes = logs
      .where((l) => sameDay(l.createdAt, now))
      .fold<int>(0, (acc, l) => acc + (l.durationSeconds ~/ 60));

  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);

  final weekMinutes = logs
      .where((l) => !l.createdAt.isBefore(weekStartDay))
      .fold<int>(0, (acc, l) => acc + (l.durationSeconds ~/ 60));

  return DerivedStats(
    totalSessions: logs.length,
    minutesToday: todayMinutes,
    minutesThisWeek: weekMinutes,
  );
});
