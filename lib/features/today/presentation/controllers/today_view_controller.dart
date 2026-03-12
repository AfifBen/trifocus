import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/local_storage.dart';

enum TodayViewMode { cards, timeline }

final todayViewProvider =
    StateNotifierProvider<TodayViewController, TodayViewMode>(
  (ref) => TodayViewController()..load(),
);

class TodayViewController extends StateNotifier<TodayViewMode> {
  TodayViewController() : super(TodayViewMode.cards);

  Future<void> load() async {
    final raw = await LocalStorage.loadTodayViewMode();
    if (raw == 'timeline') {
      state = TodayViewMode.timeline;
    } else {
      state = TodayViewMode.cards;
    }
  }

  Future<void> toggle() async {
    state = state == TodayViewMode.cards ? TodayViewMode.timeline : TodayViewMode.cards;
    await LocalStorage.saveTodayViewMode(state == TodayViewMode.timeline ? 'timeline' : 'cards');
  }
}
