import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BreakTimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;

  const BreakTimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isRunning,
  });

  double get progress =>
      totalSeconds == 0 ? 0 : 1 - (remainingSeconds / totalSeconds);

  BreakTimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
  }) {
    return BreakTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

final breakTimerProvider =
    StateNotifierProvider<BreakTimerController, BreakTimerState>(
  (ref) => BreakTimerController(),
);

class BreakTimerController extends StateNotifier<BreakTimerState> {
  BreakTimerController()
      : super(const BreakTimerState(
          totalSeconds: 300,
          remainingSeconds: 300,
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

  void reset(int seconds) {
    _timer?.cancel();
    _timer = null;
    state = BreakTimerState(
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
