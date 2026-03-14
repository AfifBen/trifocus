import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores the duration (in seconds) of the last focus session to be logged.
///
/// - Completed session => full configured duration
/// - Ended early => elapsed seconds
final lastSessionDurationProvider =
    StateNotifierProvider<LastSessionDurationController, int?>(
  (ref) => LastSessionDurationController(),
);

class LastSessionDurationController extends StateNotifier<int?> {
  LastSessionDurationController() : super(null);

  void set(int seconds) {
    state = seconds;
  }

  void clear() {
    state = null;
  }
}
