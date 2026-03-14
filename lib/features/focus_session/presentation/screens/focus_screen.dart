import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../goals/presentation/controllers/today_goals_controller.dart';
import '../controllers/active_goal_controller.dart';
import '../controllers/focus_settings_controller.dart';
import '../controllers/focus_timer_controller.dart';
import '../controllers/session_result_controller.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(focusTimerProvider);
    final notifier = ref.read(focusTimerProvider.notifier);
    final goals = ref.watch(todayGoalsProvider);
    final activeGoalId = ref.watch(activeGoalProvider);
    final settings = ref.watch(focusSettingsProvider);

    final availableGoals = goals
        .where((g) => g.sessionsTotal <= 0 || g.sessionsDone < g.sessionsTotal)
        .toList();

    final effectiveActiveGoalId = activeGoalId ??
        (availableGoals.isNotEmpty ? availableGoals.first.id : null);
    if (effectiveActiveGoalId != activeGoalId && availableGoals.isNotEmpty) {
      Future.microtask(() {
        ref.read(activeGoalProvider.notifier).select(effectiveActiveGoalId);
      });
    }

    if (timer.remainingSeconds == 0) {
      Future.microtask(() {
        if (context.mounted) {
          notifier.pause();
          ref.read(sessionResultProvider.notifier).setCompleted();
          context.go('/break');
        }
      });
    }

    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Focus', style: AppTextStyles.headline),
            const SizedBox(height: 12),
            if (availableGoals.isEmpty)
              const Text('No active goals. Create your 3 objectives first.',
                  style: AppTextStyles.body)
            else
              DropdownButtonFormField<String>(
                value: effectiveActiveGoalId,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                decoration: InputDecoration(
                  hintText: 'Active goal',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                items: availableGoals
                    .map(
                      (g) => DropdownMenuItem<String>(
                        value: g.id,
                        child: Text(g.title, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (id) {
                  HapticFeedback.selectionClick();
                  ref.read(activeGoalProvider.notifier).select(id);
                },
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: settings.focusSeconds,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      hintText: 'Focus',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1500, child: Text('25 min')),
                      DropdownMenuItem(value: 2700, child: Text('45 min')),
                      DropdownMenuItem(value: 3600, child: Text('60 min')),
                    ],
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      final v = value ?? 1500;
                      ref.read(focusSettingsProvider.notifier).setFocusSeconds(v);
                      if (!timer.isRunning) {
                        notifier.reset(v);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: settings.breakSeconds,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      hintText: 'Break',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 300, child: Text('5 min')),
                      DropdownMenuItem(value: 600, child: Text('10 min')),
                      DropdownMenuItem(value: 900, child: Text('15 min')),
                    ],
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      final v = value ?? 300;
                      ref.read(focusSettingsProvider.notifier).setBreakSeconds(v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: timer.progress),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 10,
                            backgroundColor: AppColors.surfaceAlt,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          );
                        },
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                        child: Text(
                          _format(timer.remainingSeconds),
                          key: ValueKey(timer.remainingSeconds),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      notifier.pause();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Pause'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      notifier.start();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Semantics(
                      button: true,
                      label: timer.isRunning ? 'Resume focus timer' : 'Start focus timer',
                      child: Text(timer.isRunning ? 'Resume' : 'Start'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(sessionResultProvider.notifier).setEndedEarly();
                  notifier.reset();
                  context.go('/session-complete');
                },
                child: const Text('End Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }
}
