import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/data/local_storage.dart';
import '../sync/cloud_sync_controller.dart';
import 'notification_service.dart';

class ReminderState {
  final bool enabled;
  final int hour;
  final int minute;
  final bool nextGoalEnabled;
  final int nextGoalLeadMinutes;

  const ReminderState({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.nextGoalEnabled,
    required this.nextGoalLeadMinutes,
  });

  ReminderState copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    bool? nextGoalEnabled,
    int? nextGoalLeadMinutes,
  }) {
    return ReminderState(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      nextGoalEnabled: nextGoalEnabled ?? this.nextGoalEnabled,
      nextGoalLeadMinutes: nextGoalLeadMinutes ?? this.nextGoalLeadMinutes,
    );
  }
}

final reminderProvider =
    StateNotifierProvider<ReminderController, ReminderState>(
  (ref) => ReminderController(ref)..load(),
);

class ReminderController extends StateNotifier<ReminderState> {
  final Ref _ref;
  ReminderController(this._ref)
      : super(const ReminderState(
          enabled: false,
          hour: 9,
          minute: 0,
          nextGoalEnabled: false,
          nextGoalLeadMinutes: 0,
        ));

  Future<void> load() async {
    final enabled = await LocalStorage.loadReminderEnabled();
    final hour = await LocalStorage.loadReminderHour();
    final minute = await LocalStorage.loadReminderMinute();
    final nextGoal = await LocalStorage.loadNextGoalReminderEnabled();
    final leadMin = await LocalStorage.loadNextGoalReminderLeadMinutes();

    state = state.copyWith(
      enabled: enabled,
      hour: hour ?? state.hour,
      minute: minute ?? state.minute,
      nextGoalEnabled: nextGoal,
      nextGoalLeadMinutes: leadMin,
    );

    await syncWithGoals();
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await LocalStorage.saveReminderEnabled(enabled);
    await syncWithGoals();
    await LocalStorage.saveCloudPending(true);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }

  Future<void> setTime({required int hour, required int minute}) async {
    state = state.copyWith(hour: hour, minute: minute);
    await LocalStorage.saveReminderTime(hour: hour, minute: minute);
    await syncWithGoals();
    await LocalStorage.saveCloudPending(true);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }

  Future<void> setNextGoalEnabled(bool enabled) async {
    state = state.copyWith(nextGoalEnabled: enabled);
    await LocalStorage.saveNextGoalReminderEnabled(enabled);
    await syncWithGoals();
    await LocalStorage.saveCloudPending(true);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }

  Future<void> setNextGoalLeadMinutes(int minutes) async {
    state = state.copyWith(nextGoalLeadMinutes: minutes);
    await LocalStorage.saveNextGoalReminderLeadMinutes(minutes);
    await syncWithGoals();
    await LocalStorage.saveCloudPending(true);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }

  Future<void> syncWithGoals() async {
    final goals = await LocalStorage.loadGoals();
    final leadMin = state.nextGoalLeadMinutes;

    // Daily reminder: only if user hasn't set 3 goals.
    if (!state.enabled) {
      await NotificationService.cancelDailyReminder();
    } else {
      if (goals.length < 3) {
        await NotificationService.scheduleDailyReminder(
          hour: state.hour,
          minute: state.minute,
        );
      } else {
        await NotificationService.cancelDailyReminder();
      }
    }

    // Next scheduled goal reminder: schedule the next upcoming scheduled goal (today).
    if (!state.nextGoalEnabled) {
      await NotificationService.cancelNextGoalReminder();
      return;
    }

    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final candidates = goals
        .where((g) => g.scheduledMinutes != null)
        .where((g) => g.sessionsDone < g.sessionsTotal)
        .where((g) => g.scheduledMinutes! > nowMin)
        .toList()
      ..sort((a, b) => a.scheduledMinutes!.compareTo(b.scheduledMinutes!));

    if (candidates.isEmpty) {
      await NotificationService.cancelNextGoalReminder();
      return;
    }

    final next = candidates.first;
    final mins = next.scheduledMinutes!;
    final when = DateTime(now.year, now.month, now.day, mins ~/ 60, mins % 60)
        .subtract(Duration(minutes: leadMin));

    // If lead time pushed it into the past, schedule at the goal time.
    final effectiveWhen = when.isBefore(now)
        ? DateTime(now.year, now.month, now.day, mins ~/ 60, mins % 60)
        : when;

    await NotificationService.scheduleNextGoalReminder(
      when: effectiveWhen,
      title: next.title,
    );
  }
}
