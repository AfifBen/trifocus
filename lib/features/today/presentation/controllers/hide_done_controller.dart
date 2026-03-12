import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/local_storage.dart';

final hideDoneProvider = StateNotifierProvider<HideDoneController, bool>(
  (ref) => HideDoneController()..load(),
);

class HideDoneController extends StateNotifier<bool> {
  HideDoneController() : super(false);

  Future<void> load() async {
    state = await LocalStorage.loadHideDoneGoals();
  }

  Future<void> toggle() async {
    state = !state;
    await LocalStorage.saveHideDoneGoals(state);
  }
}
