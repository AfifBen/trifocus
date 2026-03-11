import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/local_storage.dart';

class StatsState {
  final int totalSessions;
  final int streakDays;
  final DateTime? lastSessionDate;

  const StatsState({
    required this.totalSessions,
    required this.streakDays,
    required this.lastSessionDate,
  });

  StatsState copyWith({
    int? totalSessions,
    int? streakDays,
    DateTime? lastSessionDate,
  }) {
    return StatsState(
      totalSessions: totalSessions ?? this.totalSessions,
      streakDays: streakDays ?? this.streakDays,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }
}

final statsProvider = StateNotifierProvider<StatsController, StatsState>(
  (ref) => StatsController()..load(),
);

class StatsController extends StateNotifier<StatsState> {
  StatsController()
      : super(const StatsState(
          totalSessions: 0,
          streakDays: 0,
          lastSessionDate: null,
        ));

  Future<void> load() async {
    final data = await LocalStorage.loadStats();
    if (data.isEmpty) return;
    state = StatsState(
      totalSessions: data['totalSessions'] as int? ?? 0,
      streakDays: data['streakDays'] as int? ?? 0,
      lastSessionDate: data['lastSessionDate'] != null
          ? DateTime.tryParse(data['lastSessionDate'] as String)
          : null,
    );
  }

  Future<void> completeSession() async {
    final now = DateTime.now();
    final last = state.lastSessionDate;
    final isNewDay = last == null || !_isSameDay(now, last);
    final streak = isNewDay ? (state.streakDays + 1) : state.streakDays;

    state = state.copyWith(
      totalSessions: state.totalSessions + 1,
      streakDays: streak,
      lastSessionDate: now,
    );

    await LocalStorage.saveStats({
      'totalSessions': state.totalSessions,
      'streakDays': state.streakDays,
      'lastSessionDate': state.lastSessionDate?.toIso8601String(),
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
