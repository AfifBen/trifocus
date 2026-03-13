import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../goals/domain/models/goal.dart';
import '../../../goals/presentation/controllers/today_goals_controller.dart';
import '../../../goals/presentation/screens/create_goal_screen.dart';
import '../../../goals/presentation/screens/goal_detail_screen.dart';
import '../../../templates/presentation/controllers/templates_controller.dart';
import '../controllers/today_view_controller.dart';
import '../controllers/hide_done_controller.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(todayGoalsProvider);

    final viewMode = ref.watch(todayViewProvider);
    final hideDone = ref.watch(hideDoneProvider);

    final visibleGoals = hideDone
        ? goals
            .where(
              (g) => g.sessionsTotal <= 0 || g.sessionsDone < g.sessionsTotal,
            )
            .toList()
        : goals;

    final sortedGoals = [...visibleGoals]..sort((a, b) {
      final ad = a.sessionsDone >= a.sessionsTotal;
      final bd = b.sessionsDone >= b.sessionsTotal;
      if (ad != bd) return ad ? 1 : -1;

      final am = a.scheduledMinutes;
      final bm = b.scheduledMinutes;
      if (am == null && bm == null) return 0;
      if (am == null) return 1;
      if (bm == null) return -1;
      return am.compareTo(bm);
    });

    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.todayTitle,
                  style: AppTextStyles.headline,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          ref.read(hideDoneProvider.notifier).toggle(),
                      icon: Icon(
                        hideDone ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: hideDone ? 'Show done' : 'Hide done',
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(todayViewProvider.notifier).toggle(),
                      icon: Icon(
                        viewMode == TodayViewMode.cards
                            ? Icons.view_agenda
                            : Icons.view_module,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.todaySubtitle,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _applyTemplate(context, ref),
                icon: const Icon(Icons.auto_awesome),
                label: Text(AppLocalizations.of(context)!.applyTemplate),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: goals.isEmpty
                  ? _EmptyState(
                      onCreate: () => _openCreate(context),
                    )
                  : viewMode == TodayViewMode.cards
                      ? ListView.separated(
                          // When hiding done goals, show only visible goals (no empty slots).
                          itemCount: hideDone ? sortedGoals.length : 3,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (!hideDone && index >= sortedGoals.length) {
                              return _EmptyGoalCard(
                                index: index,
                                onTap: () => _openCreate(context),
                              );
                            }
                            final goal = sortedGoals[index];
                            return _GoalCard(
                              goal: goal,
                              onTap: () => _openFocus(context),
                              onLongPress: () => _openDetail(context, goal),
                              onTimeTap: () => _setTime(context, goal, ref),
                              onTimeClear: () => _clearTime(goal, ref),
                            );
                          },
                        )
                      : _TimelineView(
                          goals: sortedGoals,
                          onGoalLongPress: (g) => _openDetail(context, g),
                          onGoalTimeTap: (g) => _setTime(context, g, ref),
                          onGoalTimeClear: (g) => _clearTime(g, ref),
                        ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: goals.length < 3
                    ? () => _openCreate(context)
                    : () => _openFocus(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(goals.length < 3 ? 'Create Goals' : 'Start Focus'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateGoalScreen()),
    );
  }

  Future<void> _applyTemplate(BuildContext context, WidgetRef ref) async {
    final templates = ref.read(templatesProvider);
    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No templates yet.')),
      );
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Choose a template', style: AppTextStyles.title),
              ),
              ...templates.map(
                (t) => ListTile(
                  title: Text(t.name, style: AppTextStyles.title),
                  subtitle: Text(
                    t.goals.take(3).map((g) => g.title).join(' • '),
                    style: AppTextStyles.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.of(context).pop(t.id),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null) return;

    final tpl = templates.firstWhere((t) => t.id == selected);
    await ref.read(todayGoalsProvider.notifier).setGoals(
          tpl.goals.take(3).map((g) => g.copyWith(sessionsDone: 0)).toList(),
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Template applied.')),
    );
  }

  void _openDetail(BuildContext context, Goal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GoalDetailScreen(goal: goal)),
    );
  }

  Future<void> _setTime(BuildContext context, Goal goal, WidgetRef ref) async {
    final initial = goal.scheduledMinutes == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay(
            hour: goal.scheduledMinutes! ~/ 60,
            minute: goal.scheduledMinutes! % 60,
          );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    final minutes = picked.hour * 60 + picked.minute;
    await ref
        .read(todayGoalsProvider.notifier)
        .updateGoal(goal.copyWith(scheduledMinutes: minutes));
  }

  Future<void> _clearTime(Goal goal, WidgetRef ref) async {
    await ref.read(todayGoalsProvider.notifier).updateGoal(
          goal.copyWith(clearScheduledMinutes: true),
        );
  }

  void _openFocus(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    if (context.mounted) {
      context.go('/focus');
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onCreate,
            child: Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.primary, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x337C5CFF),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              child: const Center(
                child: Text(
                  'Set\nObjective',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('No goals yet', style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onTimeTap;
  final VoidCallback onTimeClear;

  const _GoalCard({
    required this.goal,
    required this.onTap,
    required this.onLongPress,
    required this.onTimeTap,
    required this.onTimeClear,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.sessionsTotal == 0
        ? 0.0
        : goal.sessionsDone / goal.sessionsTotal;
    final isDone = goal.sessionsTotal > 0 && goal.sessionsDone >= goal.sessionsTotal;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(goal.title, style: AppTextStyles.title),
                  ),
                  if (isDone)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'DONE',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              if (goal.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(goal.description, style: AppTextStyles.body),
              ],
              const SizedBox(height: 8),
              _CategoryChip(label: _categoryLabel(goal)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      minHeight: 8,
                      value: value,
                      backgroundColor: AppColors.background,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goal.sessionsDone}/${goal.sessionsTotal} sessions',
                    style: AppTextStyles.body,
                  ),
                  InkWell(
                    onTap: isDone ? null : onTimeTap,
                    onLongPress:
                        (isDone || goal.scheduledMinutes == null) ? null : onTimeClear,
                    child: Text(
                      goal.scheduledMinutes == null
                          ? (isDone ? '' : 'Set time')
                          : _formatTime(goal.scheduledMinutes!),
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _categoryLabel(Goal goal) {
    final typeLabel = switch (goal.categoryType) {
      'project' => 'Project',
      'habit' => 'Habit',
      'path' => 'Path',
      _ => 'Work',
    };
    if (goal.categoryItem.isEmpty) return typeLabel;
    return '$typeLabel · ${goal.categoryItem}';
  }
}

class _EmptyGoalCard extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const _EmptyGoalCard({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceAlt,
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Tap to set objective', style: AppTextStyles.body),
            ),
            const Icon(Icons.add, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineView extends StatelessWidget {
  final List<Goal> goals;
  final ValueChanged<Goal> onGoalLongPress;
  final ValueChanged<Goal> onGoalTimeTap;
  final ValueChanged<Goal> onGoalTimeClear;

  const _TimelineView({
    required this.goals,
    required this.onGoalLongPress,
    required this.onGoalTimeTap,
    required this.onGoalTimeClear,
  });

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;

    return ListView.separated(
      itemCount: goals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final g = goals[index];
        final t = g.scheduledMinutes;
        final isDone = g.sessionsTotal > 0 && g.sessionsDone >= g.sessionsTotal;
        final timeLabel = t == null ? (isDone ? 'Done' : 'Set time') : _formatTime(t);
        final isPast = t != null && t <= nowMin;

        return GestureDetector(
          onLongPress: () => onGoalLongPress(g),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: isDone ? null : () => onGoalTimeTap(g),
                  onLongPress: (isDone || g.scheduledMinutes == null)
                      ? null
                      : () => onGoalTimeClear(g),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 72,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      timeLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.title,
                          style: AppTextStyles.title,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(
                        '${g.sessionsDone}/${g.sessionsTotal} sessions',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
                if (isPast)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Now',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
    );
  }
}
