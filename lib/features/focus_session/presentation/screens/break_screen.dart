import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../controllers/break_timer_controller.dart';
import '../controllers/focus_settings_controller.dart';

class BreakScreen extends ConsumerWidget {
  const BreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(focusSettingsProvider);
    final timer = ref.watch(breakTimerProvider);
    final notifier = ref.read(breakTimerProvider.notifier);

    // Ensure timer matches current settings.
    if (!timer.isRunning && timer.totalSeconds != settings.breakSeconds) {
      Future.microtask(() => notifier.reset(settings.breakSeconds));
    }

    // Autostart when entering break screen.
    if (!timer.isRunning && timer.remainingSeconds > 0) {
      Future.microtask(notifier.start);
    }

    if (timer.remainingSeconds == 0) {
      Future.microtask(() {
        if (context.mounted) {
          context.go('/session-complete');
        }
      });
    }

    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Break', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            Text(
              'Take ${settings.breakSeconds ~/ 60} minutes to reset.',
              style: AppTextStyles.body,
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
                    child: Text(timer.isRunning ? 'Resume' : 'Start'),
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
                  context.go('/session-complete');
                },
                child: const Text('Skip Break'),
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
