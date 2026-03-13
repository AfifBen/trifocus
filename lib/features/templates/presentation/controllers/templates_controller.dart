import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/local_storage.dart';
import '../../../sync/cloud_sync_controller.dart';
import '../../domain/models/goal_template.dart';

final templatesProvider =
    StateNotifierProvider<TemplatesController, List<GoalTemplate>>(
  (ref) => TemplatesController(ref)..load(),
);

class TemplatesController extends StateNotifier<List<GoalTemplate>> {
  final Ref _ref;
  TemplatesController(this._ref) : super(const []);

  Future<void> load() async {
    final items = await LocalStorage.loadTemplates();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = items;
  }

  Future<void> add(GoalTemplate template) async {
    final next = [template, ...state];
    state = next;
    await LocalStorage.saveTemplates(next);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }

  Future<void> remove(String id) async {
    final next = state.where((t) => t.id != id).toList();
    state = next;
    await LocalStorage.saveTemplates(next);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }

  Future<void> rename(String id, String name) async {
    final next = state
        .map(
          (t) => t.id == id
              ? GoalTemplate(
                  id: t.id,
                  name: name,
                  createdAt: t.createdAt,
                  goals: t.goals,
                )
              : t,
        )
        .toList();
    state = next;
    await LocalStorage.saveTemplates(next);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }

  Future<void> duplicate(String id) async {
    final tpl = state.where((t) => t.id == id).firstOrNull;
    if (tpl == null) return;
    await add(
      GoalTemplate(
        id: 'tpl_${DateTime.now().millisecondsSinceEpoch}',
        name: '${tpl.name} (copy)',
        createdAt: DateTime.now(),
        goals: tpl.goals,
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
