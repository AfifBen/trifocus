import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/goal.dart';

final todayGoalsProvider = StateNotifierProvider<TodayGoalsController, List<Goal>>(
  (ref) => TodayGoalsController(),
);

class TodayGoalsController extends StateNotifier<List<Goal>> {
  TodayGoalsController()
      : super(const [
          Goal(
            id: 'goal_1',
            title: 'Ship Sprint 2 UI',
            categoryType: 'project',
            categoryItem: 'TriFocus',
            description: 'Finish Today + Create Goal + Detail',
            sessionsDone: 1,
            sessionsTotal: 4,
          ),
          Goal(
            id: 'goal_2',
            title: 'Read product doc',
            categoryType: 'habit',
            categoryItem: 'Reading',
            description: '15 pages focused reading',
            sessionsDone: 0,
            sessionsTotal: 2,
          ),
          Goal(
            id: 'goal_3',
            title: 'Workout',
            categoryType: 'work',
            categoryItem: 'Health',
            description: '30 min strength session',
            sessionsDone: 0,
            sessionsTotal: 1,
          ),
        ]);

  void updateGoal(Goal updated) {
    state = state.map((g) => g.id == updated.id ? updated : g).toList();
  }

  void setGoals(List<Goal> goals) {
    state = goals.take(3).toList();
  }
}
