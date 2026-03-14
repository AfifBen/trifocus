import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/local_storage.dart';
import '../../../sync/cloud_sync_controller.dart';

final hideDoneProvider = StateNotifierProvider<HideDoneController, bool>(
  (ref) => HideDoneController(ref)..load(),
);

class HideDoneController extends StateNotifier<bool> {
  final Ref _ref;
  HideDoneController(this._ref) : super(false);

  Future<void> load() async {
    state = await LocalStorage.loadHideDoneGoals();
  }

  Future<void> toggle() async {
    state = !state;
    await LocalStorage.saveHideDoneGoals(state);
    await LocalStorage.saveCloudPending(true);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }
}
