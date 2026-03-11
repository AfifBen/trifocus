import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/data/local_storage.dart';
import 'notification_service.dart';

class ReminderState {
  final bool enabled;
  final int hour;
  final int minute;

  const ReminderState({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  ReminderState copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return ReminderState(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}

final reminderProvider =
    StateNotifierProvider<ReminderController, ReminderState>(
  (ref) => ReminderController()..load(),
);

class ReminderController extends StateNotifier<ReminderState> {
  ReminderController()
      : super(const ReminderState(enabled: false, hour: 9, minute: 0));

  Future<void> load() async {
    final enabled = await LocalStorage.loadReminderEnabled();
    final hour = await LocalStorage.loadReminderHour();
    final minute = await LocalStorage.loadReminderMinute();
    state = state.copyWith(
      enabled: enabled,
      hour: hour ?? state.hour,
      minute: minute ?? state.minute,
    );

    if (state.enabled) {
      await NotificationService.scheduleDailyReminder(
        hour: state.hour,
        minute: state.minute,
      );
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await LocalStorage.saveReminderEnabled(enabled);

    if (!enabled) {
      await NotificationService.cancelDailyReminder();
    } else {
      await NotificationService.scheduleDailyReminder(
        hour: state.hour,
        minute: state.minute,
      );
    }
  }

  Future<void> setTime({required int hour, required int minute}) async {
    state = state.copyWith(hour: hour, minute: minute);
    await LocalStorage.saveReminderTime(hour: hour, minute: minute);

    if (state.enabled) {
      await NotificationService.scheduleDailyReminder(hour: hour, minute: minute);
    }
  }
}
