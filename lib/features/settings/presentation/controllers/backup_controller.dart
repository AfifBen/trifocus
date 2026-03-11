import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_storage.dart';
import '../../../focus_session/presentation/controllers/focus_settings_controller.dart';
import '../../../goals/presentation/controllers/today_goals_controller.dart';
import '../../../library/presentation/controllers/library_controller.dart';
import '../../../notifications/reminder_controller.dart';
import '../../../stats/presentation/controllers/stats_controller.dart';

final backupProvider = Provider<BackupController>((ref) => BackupController(ref));

class BackupController {
  final Ref _ref;
  BackupController(this._ref);

  Future<String> exportJson() async {
    final data = await LocalStorage.exportAll();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> importJson(String json) async {
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid JSON format');
    }
    await LocalStorage.importAll(decoded);

    // Refresh providers that depend on storage.
    _ref.invalidate(focusSettingsProvider);
    _ref.invalidate(todayGoalsProvider);
    _ref.invalidate(statsProvider);
    _ref.invalidate(libraryProvider);
    _ref.invalidate(reminderProvider);
  }
}
