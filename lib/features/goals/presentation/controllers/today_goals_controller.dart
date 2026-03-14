import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/goal.dart';
import '../../../core/data/local_storage.dart';
import '../../../notifications/reminder_controller.dart';
import '../../../sync/cloud_sync_controller.dart';

final todayGoalsProvider = StateNotifierProvider<TodayGoalsController, List<Goal>>(
  (ref) => TodayGoalsController(ref)..load(),
);

class TodayGoalsController extends StateNotifier<List<Goal>> {
  final Ref _ref;
  TodayGoalsController(this._ref) : super(const []);

  Future<void> load() async {
    final goals = await LocalStorage.loadGoals();

    final today = _dayKey(DateTime.now());
    final storedDay = await LocalStorage.loadGoalsDay();

    final shouldReset = storedDay != null && storedDay != today;
    final next = goals.take(3).toList();

    if (shouldReset && next.isNotEmpty) {
      final reset = next.map((g) => g.copyWith(sessionsDone: 0)).toList();
      state = reset;
      await LocalStorage.saveGoals(reset);
    } else {
      state = next;
    }

    await LocalStorage.saveGoalsDay(today);
    await _ref.read(reminderProvider.notifier).syncWithGoals();

    // Only push to cloud when we actually mutated local data (e.g., daily reset).
    if (shouldReset && next.isNotEmpty) {
      await LocalStorage.saveCloudPending(true);
      await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
    }
  }

  Future<void> updateGoal(Goal updated) async {
    state = state.map((g) => g.id == updated.id ? updated : g).toList();
    await LocalStorage.saveGoals(state);
    await _ref.read(reminderProvider.notifier).syncWithGoals();
    await LocalStorage.saveCloudPending(true);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }

  Future<void> setGoals(List<Goal> goals) async {
    state = goals.take(3).toList();
    await LocalStorage.saveGoals(state);
    await LocalStorage.saveGoalsDay(_dayKey(DateTime.now()));
    await _ref.read(reminderProvider.notifier).syncWithGoals();
    await LocalStorage.saveCloudPending(true);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }

  Future<void> resetTodayProgress() async {
    final reset = state.map((g) => g.copyWith(sessionsDone: 0)).toList();
    state = reset;
    await LocalStorage.saveGoals(reset);
    await LocalStorage.saveGoalsDay(_dayKey(DateTime.now()));
    await _ref.read(reminderProvider.notifier).syncWithGoals();
    await LocalStorage.saveCloudPending(true);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }

  String _dayKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
