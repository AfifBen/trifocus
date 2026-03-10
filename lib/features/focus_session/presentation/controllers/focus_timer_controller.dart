import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FocusTimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;

  const FocusTimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isRunning,
  });

  double get progress =>
      totalSeconds == 0 ? 0 : 1 - (remainingSeconds / totalSeconds);

  FocusTimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
  }) {
    return FocusTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerController, FocusTimerState>(
  (ref) => FocusTimerController(),
);

class FocusTimerController extends StateNotifier<FocusTimerState> {
  FocusTimerController()
      : super(const FocusTimerState(
          totalSeconds: 1500,
          remainingSeconds: 1500,
          isRunning: false,
        ));

  Timer? _timer;

  void start() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 1) {
        pause();
        state = state.copyWith(remainingSeconds: 0);
        return;
      }
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    });
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  void reset([int seconds = 1500]) {
    _timer?.cancel();
    _timer = null;
    state = FocusTimerState(
      totalSeconds: seconds,
      remainingSeconds: seconds,
      isRunning: false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
