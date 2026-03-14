import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../history/domain/models/focus_log.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../stats/presentation/controllers/stats_controller.dart';

class ProgressWorldState {
  final int totalXp;
  final int level;
  final String stageName;
  final int stageIndex;
  final int xpIntoStage;
  final int xpForNextStage;
  final double streakMultiplier;
  final int completedSessions;

  const ProgressWorldState({
    required this.totalXp,
    required this.level,
    required this.stageName,
    required this.stageIndex,
    required this.xpIntoStage,
    required this.xpForNextStage,
    required this.streakMultiplier,
    required this.completedSessions,
  });
}

final progressWorldProvider = Provider<ProgressWorldState>((ref) {
  final logs = ref.watch(historyProvider);
  final streakDays = ref.watch(statsProvider).streakDays;

  // Progress counts both completed and endedEarly (but endedEarly contributes
  // less automatically because durationSeconds is the elapsed time).
  final counted = logs;

  int _mins(int seconds) => seconds == 0 ? 0 : (seconds / 60).ceil();

  final minutes = counted.fold<int>(
    0,
    (acc, l) => acc + _mins(l.durationSeconds),
  );

  final sessions = counted.length;

  final multiplier = switch (streakDays) {
    >= 14 => 1.3,
    >= 7 => 1.2,
    >= 3 => 1.1,
    _ => 1.0,
  };

  // XP rule: completed minutes + (5 XP per completed session), then streak multiplier.
  final rawXp = minutes + (sessions * 5);
  final totalXp = (rawXp * multiplier).round();

  // Simple level curve.
  int levelForXp(int xp) {
    if (xp < 60) return 1;
    if (xp < 150) return 2;
    if (xp < 300) return 3;
    if (xp < 500) return 4;
    if (xp < 800) return 5;
    if (xp < 1200) return 6;
    if (xp < 1700) return 7;
    if (xp < 2300) return 8;
    return 9;
  }

  const stages = <Map<String, dynamic>>[
    {'name': 'Seed', 'xp': 0},
    {'name': 'Sprout', 'xp': 100},
    {'name': 'Sapling', 'xp': 250},
    {'name': 'Tree', 'xp': 450},
    {'name': 'Forest', 'xp': 700},
    {'name': 'City', 'xp': 1000},
    {'name': 'Kingdom', 'xp': 1400},
    {'name': 'Empire', 'xp': 1900},
    {'name': 'Mythic', 'xp': 2500},
  ];

  int stageIndex = 0;
  for (var i = 0; i < stages.length; i++) {
    final threshold = stages[i]['xp'] as int;
    if (totalXp >= threshold) stageIndex = i;
  }

  final currentXp = stages[stageIndex]['xp'] as int;
  final nextXp = stageIndex + 1 < stages.length
      ? (stages[stageIndex + 1]['xp'] as int)
      : (currentXp + 500);

  return ProgressWorldState(
    totalXp: totalXp,
    level: levelForXp(totalXp),
    stageName: stages[stageIndex]['name'] as String,
    stageIndex: stageIndex,
    xpIntoStage: (totalXp - currentXp).clamp(0, 1 << 30),
    xpForNextStage: (nextXp - currentXp).clamp(1, 1 << 30),
    streakMultiplier: multiplier,
    completedSessions: sessions,
  );
});
