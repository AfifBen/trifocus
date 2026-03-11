import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../core/data/local_storage.dart';
import '../../../focus_session/presentation/controllers/focus_settings_controller.dart';
import '../../../goals/presentation/controllers/today_goals_controller.dart';
import '../../../notifications/reminder_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(focusSettingsProvider);
    final reminder = ref.watch(reminderProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.background,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                'Set your 3 goals at ${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}',
                style: AppTextStyles.body,
              ),
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
                        'This will remove goals, stats, and library items. This cannot be undone.',
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
