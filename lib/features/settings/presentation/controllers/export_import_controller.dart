import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../history/presentation/controllers/history_controller.dart';

final exportImportProvider = Provider<ExportImportController>((ref) {
  return ExportImportController(ref);
});

class ExportImportController {
  final Ref _ref;
  ExportImportController(this._ref);

  Future<void> exportHistoryCsv() async {
    final logs = _ref.read(historyProvider);
    final csv = StringBuffer('date,goal,duration_min,status\n');
    for (final l in logs) {
      final date = l.createdAt.toIso8601String();
      final goal = (l.goalTitle ?? '').replaceAll('"', '""');
      final mins = (l.durationSeconds / 60).round();
      final status = l.status.name;
      csv.writeln('"$date","$goal",$mins,$status');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/trifocus_history.csv');
    await file.writeAsString(csv.toString());

    await Share.shareXFiles([XFile(file.path)], text: 'TriFocus history export');
  }

  Future<void> exportWeeklyReportTxt() async {
    final logs = _ref.read(historyProvider);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final weekLogs = logs
        .where((l) => l.createdAt.isAfter(weekStartDay))
        .where((l) => l.status.name == 'completed')
        .toList();

    final totalMin = weekLogs.fold<int>(0, (acc, l) => acc + (l.durationSeconds ~/ 60));

    final report = StringBuffer();
    report.writeln('Weekly Focus Report');
    report.writeln('Week of ${weekStartDay.toIso8601String().split('T').first}');
    report.writeln('Total focus: ${totalMin} min');
    report.writeln('Sessions: ${weekLogs.length}');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/trifocus_weekly_report.txt');
    await file.writeAsString(report.toString());

    await Share.shareXFiles([XFile(file.path)], text: 'TriFocus weekly report');
  }

  Future<void> importHistoryCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    // For now, just copy to clipboard as a sanity check.
    final bytes = result.files.first.bytes;
    if (bytes == null) return;
    final text = String.fromCharCodes(bytes);
    await Clipboard.setData(ClipboardData(text: text));
  }
}
