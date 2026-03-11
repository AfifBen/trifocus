import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/goal.dart';
import '../../../core/data/local_storage.dart';

final todayGoalsProvider = StateNotifierProvider<TodayGoalsController, List<Goal>>(
  (ref) => TodayGoalsController()..load(),
);

class TodayGoalsController extends StateNotifier<List<Goal>> {
  TodayGoalsController() : super(const []);

  Future<void> load() async {
    final goals = await LocalStorage.loadGoals();
    state = goals.take(3).toList();
  }

  Future<void> updateGoal(Goal updated) async {
    state = state.map((g) => g.id == updated.id ? updated : g).toList();
    await LocalStorage.saveGoals(state);
  }

  Future<void> setGoals(List<Goal> goals) async {
    state = goals.take(3).toList();
    await LocalStorage.saveGoals(state);
  }
}
