import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/local_storage.dart';
import '../../../sync/cloud_sync_controller.dart';
import '../../domain/models/focus_log.dart';

final historyProvider = StateNotifierProvider<HistoryController, List<FocusLog>>(
  (ref) => HistoryController(ref)..load(),
);

class HistoryController extends StateNotifier<List<FocusLog>> {
  final Ref _ref;
  HistoryController(this._ref) : super(const []);

  Future<void> load() async {
    final items = await LocalStorage.loadFocusLogs();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = items;
  }

  Future<void> add(FocusLog log) async {
    final next = [log, ...state];
    state = next;
    await LocalStorage.saveFocusLogs(next);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }

  Future<void> clear() async {
    state = const [];
    await LocalStorage.saveFocusLogs(const []);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }
}
