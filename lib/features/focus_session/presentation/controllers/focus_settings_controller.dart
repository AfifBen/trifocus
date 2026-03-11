import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/local_storage.dart';

class FocusSettingsState {
  final int focusSeconds;
  final int breakSeconds;

  const FocusSettingsState({
    required this.focusSeconds,
    required this.breakSeconds,
  });

  FocusSettingsState copyWith({
    int? focusSeconds,
    int? breakSeconds,
  }) {
    return FocusSettingsState(
      focusSeconds: focusSeconds ?? this.focusSeconds,
      breakSeconds: breakSeconds ?? this.breakSeconds,
    );
  }
}

final focusSettingsProvider =
    StateNotifierProvider<FocusSettingsController, FocusSettingsState>(
  (ref) => FocusSettingsController()..load(),
);

class FocusSettingsController extends StateNotifier<FocusSettingsState> {
  FocusSettingsController()
      : super(const FocusSettingsState(focusSeconds: 1500, breakSeconds: 300));

  Future<void> load() async {
    final focus = await LocalStorage.loadFocusDurationSeconds();
    final brk = await LocalStorage.loadBreakDurationSeconds();
    state = state.copyWith(
      focusSeconds: focus ?? state.focusSeconds,
      breakSeconds: brk ?? state.breakSeconds,
    );
  }

  Future<void> setFocusSeconds(int seconds) async {
    state = state.copyWith(focusSeconds: seconds);
    await LocalStorage.saveFocusDurationSeconds(seconds);
  }

  Future<void> setBreakSeconds(int seconds) async {
    state = state.copyWith(breakSeconds: seconds);
    await LocalStorage.saveBreakDurationSeconds(seconds);
  }
}
