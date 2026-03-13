import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../core/data/local_storage.dart';
import '../../../focus_session/presentation/controllers/focus_settings_controller.dart';
import '../../../goals/presentation/controllers/today_goals_controller.dart';
import '../../../notifications/reminder_controller.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../templates/presentation/controllers/templates_controller.dart';
import '../../../templates/domain/models/goal_template.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../sync/cloud_sync_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/backup_controller.dart';
import '../controllers/locale_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(focusSettingsProvider);
    final reminder = ref.watch(reminderProvider);
    final templates = ref.watch(templatesProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
        backgroundColor: AppColors.background,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.accountTitle,
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: ref.watch(localeProvider)?.languageCode ?? 'system',
              isExpanded: true,
              dropdownColor: AppColors.surface,
              decoration: _decoration('Language'),
              items: const [
                DropdownMenuItem(value: 'system', child: Text('System')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (v) {
                final code = v ?? 'system';
                ref.read(localeProvider.notifier).setLocale(
                      code == 'system' ? null : Locale(code),
                    );
              },
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 12),
            ref.watch(authStateProvider).when(
                  data: (user) {
                    final signedIn = user != null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton(
                          onPressed: () =>
                              context.push(signedIn ? '/account' : '/auth'),
                          child: Text(signedIn ? 'Account' : 'Sign in to sync'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: !signedIn
                              ? null
                              : () => ref
                                  .read(cloudSyncProvider.notifier)
                                  .pushIfSignedIn(),
                          child: const Text('Sync now'),
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final sync = ref.watch(cloudSyncProvider);
                            final status = sync.syncing
                                ? 'Syncing…'
                                : (sync.conflict
                                    ? 'Conflict detected'
                                    : (sync.pending
                                        ? 'Pending changes'
                                        : (sync.lastSyncedAt == null
                                            ? 'Not synced yet'
                                            : 'Last synced: ${sync.lastSyncedAt!.hour.toString().padLeft(2, '0')}:${sync.lastSyncedAt!.minute.toString().padLeft(2, '0')}')));
                            return Text(status, style: AppTextStyles.body);
                          },
                        ),
                        if (ref.watch(cloudSyncProvider).conflict)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => ref
                                      .read(cloudSyncProvider.notifier)
                                      .useCloudVersion(),
                                  child: const Text('Use cloud'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => ref
                                      .read(cloudSyncProvider.notifier)
                                      .keepLocalVersion(),
                                  child: const Text('Keep local'),
                                ),
                              ),
                            ],
                          ),
                        if (ref.watch(cloudSyncProvider).lastError != null)
                          Text(
                            'Sync error: ${ref.watch(cloudSyncProvider).lastError}',
                            style: AppTextStyles.body,
                          ),
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => const SizedBox.shrink(),
                ),
            const SizedBox(height: 28),
            const Text('Timer', style: AppTextStyles.title),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: settings.focusSeconds,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    decoration: _decoration('Focus'),
                    items: const [
                      DropdownMenuItem(value: 1500, child: Text('25 min')),
                      DropdownMenuItem(value: 2700, child: Text('45 min')),
                      DropdownMenuItem(value: 3600, child: Text('60 min')),
                    ],
                    onChanged: (value) => ref
                        .read(focusSettingsProvider.notifier)
                        .setFocusSeconds(value ?? 1500),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: settings.breakSeconds,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    decoration: _decoration('Break'),
                    items: const [
                      DropdownMenuItem(value: 300, child: Text('5 min')),
                      DropdownMenuItem(value: 600, child: Text('10 min')),
                      DropdownMenuItem(value: 900, child: Text('15 min')),
                    ],
                    onChanged: (value) => ref
                        .read(focusSettingsProvider.notifier)
                        .setBreakSeconds(value ?? 300),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Reminder', style: AppTextStyles.title),
            const SizedBox(height: 12),
            SwitchListTile(
              value: reminder.enabled,
              onChanged: (v) => ref.read(reminderProvider.notifier).setEnabled(v),
              title: const Text('Daily reminder'),
              subtitle: Text(
                'Only if goals are not set (less than 3). Time: ${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}',
                style: AppTextStyles.body,
              ),
            ),
            SwitchListTile(
              value: reminder.nextGoalEnabled,
              onChanged: (v) =>
                  ref.read(reminderProvider.notifier).setNextGoalEnabled(v),
              title: const Text('Next scheduled goal reminder'),
              subtitle: const Text(
                'Remind you for the next planned objective.',
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Lead time', style: AppTextStyles.body),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: reminder.nextGoalLeadMinutes,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    decoration: _decoration('Lead'),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('At time')),
                      DropdownMenuItem(value: 5, child: Text('5 min before')),
                      DropdownMenuItem(value: 10, child: Text('10 min before')),
                    ],
                    onChanged: !reminder.nextGoalEnabled
                        ? null
                        : (v) => ref
                            .read(reminderProvider.notifier)
                            .setNextGoalLeadMinutes(v ?? 0),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: !reminder.enabled
                    ? null
                    : () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: reminder.hour,
                            minute: reminder.minute,
                          ),
                        );
                        if (time == null) return;
                        await ref.read(reminderProvider.notifier).setTime(
                              hour: time.hour,
                              minute: time.minute,
                            );
                      },
                child: const Text('Change reminder time'),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Templates', style: AppTextStyles.title),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final controller = TextEditingController(text: 'My Template');
                  final name = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Save template'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration:
                            const InputDecoration(hintText: 'Template name'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pop(controller.text.trim()),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );

                  if (name == null || name.isEmpty) return;

                  final goals = ref.read(todayGoalsProvider);
                  if (goals.length < 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('You need 3 goals to create a template.')),
                    );
                    return;
                  }

                  await ref.read(templatesProvider.notifier).add(
                        GoalTemplate(
                          id: 'tpl_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          createdAt: DateTime.now(),
                          goals: goals,
                        ),
                      );

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Template saved.')),
                  );
                },
                child: const Text('Save current 3 goals as template'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final controller = TextEditingController();
                  final json = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Import template JSON'),
                      content: SizedBox(
                        width: 500,
                        child: TextField(
                          controller: controller,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            hintText: 'Paste template JSON here',
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pop(controller.text.trim()),
                          child: const Text('Import'),
                        ),
                      ],
                    ),
                  );

                  if (json == null || json.isEmpty) return;

                  try {
                    final decoded = jsonDecode(json) as Map<String, dynamic>;
                    final tpl = GoalTemplate.fromJson(decoded).copyWith(
                      id: 'tpl_${DateTime.now().millisecondsSinceEpoch}',
                      createdAt: DateTime.now(),
                    );
                    await ref.read(templatesProvider.notifier).add(tpl);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Template imported.')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Import failed: $e')),
                    );
                  }
                },
                child: const Text('Import template (JSON)'),
              ),
            ),
            const SizedBox(height: 12),
            if (templates.isEmpty)
              const Text('No templates yet', style: AppTextStyles.body)
            else
              Column(
                children: templates.map((t) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.name,
                              style: AppTextStyles.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .read(todayGoalsProvider.notifier)
                                  .setGoals(
                                    t.goals
                                        .take(3)
                                        .map((g) => g.copyWith(sessionsDone: 0))
                                        .toList(),
                                  );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Template applied.')),
                                );
                                context.go('/today');
                              }
                            },
                            child: const Text('Apply'),
                          ),
                          IconButton(
                            onPressed: () async {
                              final controller =
                                  TextEditingController(text: t.name);
                              final name = await showDialog<String>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Rename template'),
                                  content: TextField(
                                    controller: controller,
                                    autofocus: true,
                                    decoration: const InputDecoration(
                                      hintText: 'Template name',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context)
                                          .pop(controller.text.trim()),
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ),
                              );
                              if (name == null || name.isEmpty) return;
                              await ref
                                  .read(templatesProvider.notifier)
                                  .rename(t.id, name);
                            },
                            icon: const Icon(Icons.edit,
                                color: AppColors.textMuted),
                            tooltip: 'Rename',
                          ),
                          IconButton(
                            onPressed: () => ref
                                .read(templatesProvider.notifier)
                                .duplicate(t.id),
                            icon: const Icon(Icons.copy,
                                color: AppColors.textMuted),
                            tooltip: 'Duplicate',
                          ),
                          IconButton(
                            onPressed: () {
                              final json = const JsonEncoder.withIndent('  ')
                                  .convert(t.toJson());
                              Clipboard.setData(ClipboardData(text: json));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Template JSON copied.')),
                              );
                            },
                            icon: const Icon(Icons.share,
                                color: AppColors.textMuted),
                            tooltip: 'Copy JSON',
                          ),
                          IconButton(
                            onPressed: () => ref
                                .read(templatesProvider.notifier)
                                .remove(t.id),
                            icon: const Icon(Icons.delete,
                                color: AppColors.textMuted),
                            tooltip: 'Delete',
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 28),
            const Text('Backup', style: AppTextStyles.title),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final json = await ref.read(backupProvider).exportJson();
                  if (!context.mounted) return;
                  await showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Export JSON'),
                      content: SizedBox(
                        width: 500,
                        child: SingleChildScrollView(
                          child: SelectableText(json),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Export data (JSON)'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final logs = ref.read(historyProvider);
                  final csv = StringBuffer('date,goal,duration_min,status\n');
                  for (final l in logs) {
                    final date = l.createdAt.toIso8601String();
                    final goal = (l.goalTitle ?? '').replaceAll('"', '""');
                    final mins = (l.durationSeconds / 60).round();
                    final status = l.status.name;
                    csv.writeln('"$date","$goal",$mins,$status');
                  }
                  await Clipboard.setData(ClipboardData(text: csv.toString()));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History CSV copied.')),
                  );
                },
                child: const Text('Export history (CSV to clipboard)'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final logs = ref.read(historyProvider);
                  final now = DateTime.now();
                  final weekStart = now.subtract(Duration(days: now.weekday - 1));
                  final weekStartDay =
                      DateTime(weekStart.year, weekStart.month, weekStart.day);

                  final weekLogs = logs
                      .where((l) => l.createdAt.isAfter(weekStartDay))
                      .where((l) => l.status.name == 'completed')
                      .toList();

                  final totalMin = weekLogs.fold<int>(
                    0,
                    (acc, l) => acc + (l.durationSeconds ~/ 60),
                  );

                  final report = StringBuffer();
                  report.writeln('Weekly Focus Report');
                  report.writeln('Week of ${weekStartDay.toIso8601String().split('T').first}');
                  report.writeln('Total focus: ${totalMin} min');
                  report.writeln('Sessions: ${weekLogs.length}');

                  await Clipboard.setData(ClipboardData(text: report.toString()));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Weekly report copied.')),
                  );
                },
                child: const Text('Copy weekly report'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final controller = TextEditingController();
                  final json = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Import JSON'),
                      content: SizedBox(
                        width: 500,
                        child: TextField(
                          controller: controller,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            hintText: 'Paste JSON here',
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pop(controller.text.trim()),
                          child: const Text('Import'),
                        ),
                      ],
                    ),
                  );

                  if (json == null || json.isEmpty) return;

                  try {
                    await ref.read(backupProvider).importJson(json);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Import complete.')),
                    );
                    context.go('/');
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Import failed: $e')),
                    );
                  }
                },
                child: const Text('Import data (JSON)'),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Data', style: AppTextStyles.title),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(todayGoalsProvider.notifier).resetTodayProgress();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Today progress reset.')),
                    );
                  }
                },
                child: const Text('Reset today progress'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear history?'),
                      content: const Text('This will remove all focus session logs.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                  if (ok != true) return;

                  await ref.read(historyProvider.notifier).clear();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('History cleared.')),
                    );
                  }
                },
                child: const Text('Clear history'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                ),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear all data?'),
                      content: const Text(
                        'This will remove goals, stats, library items, and history. This cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: AppColors.textPrimary,
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                  if (ok != true) return;

                  await LocalStorage.clearAll();

                  // Refresh providers.
                  ref.invalidate(todayGoalsProvider);
                  ref.invalidate(focusSettingsProvider);
                  ref.invalidate(reminderProvider);
                  ref.invalidate(historyProvider);

                  if (context.mounted) context.go('/');
                },
                child: const Text('Clear all data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}
