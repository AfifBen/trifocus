import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SessionResult { completed, endedEarly }

final sessionResultProvider =
    StateNotifierProvider<SessionResultController, SessionResult>(
  (ref) => SessionResultController(),
);

class SessionResultController extends StateNotifier<SessionResult> {
  SessionResultController() : super(SessionResult.completed);

  void setCompleted() => state = SessionResult.completed;

  void setEndedEarly() => state = SessionResult.endedEarly;
}
