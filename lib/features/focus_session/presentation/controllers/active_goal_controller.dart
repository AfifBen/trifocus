import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeGoalProvider = StateNotifierProvider<ActiveGoalController, String?>(
  (ref) => ActiveGoalController(),
);

class ActiveGoalController extends StateNotifier<String?> {
  ActiveGoalController() : super(null);

  void select(String? goalId) {
    state = goalId;
  }
}
