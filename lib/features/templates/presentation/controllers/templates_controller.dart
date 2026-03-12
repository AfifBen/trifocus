import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/local_storage.dart';
import '../../domain/models/goal_template.dart';

final templatesProvider =
    StateNotifierProvider<TemplatesController, List<GoalTemplate>>(
  (ref) => TemplatesController()..load(),
);

class TemplatesController extends StateNotifier<List<GoalTemplate>> {
  TemplatesController() : super(const []);

  Future<void> load() async {
    final items = await LocalStorage.loadTemplates();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = items;
  }

  Future<void> add(GoalTemplate template) async {
    final next = [template, ...state];
    state = next;
    await LocalStorage.saveTemplates(next);
  }

  Future<void> remove(String id) async {
    final next = state.where((t) => t.id != id).toList();
    state = next;
    await LocalStorage.saveTemplates(next);
  }
}
