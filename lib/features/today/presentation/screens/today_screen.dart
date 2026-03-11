import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../goals/domain/models/goal.dart';
import '../../../goals/presentation/controllers/today_goals_controller.dart';
import '../../../goals/presentation/screens/create_goal_screen.dart';
import '../../../goals/presentation/screens/goal_detail_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(todayGoalsProvider);

    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            const Text('Three goals. One day.', style: AppTextStyles.body),
            const SizedBox(height: 24),
            Expanded(
              child: goals.isEmpty
                  ? _EmptyState(
                      onCreate: () => _openCreate(context),
                    )
                  : ListView.separated(
                      itemCount: 3,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index >= goals.length) {
                          return _EmptyGoalCard(
                            index: index,
                            onTap: () => _openCreate(context),
                          );
                        }
                        final goal = goals[index];
                        return _GoalCard(
                          goal: goal,
                          onTap: () => _openFocus(context),
                          onLongPress: () => _openDetail(context, goal),
                        );
                      },
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

  void _openDetail(BuildContext context, Goal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GoalDetailScreen(goal: goal)),
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

  const _GoalCard({
    required this.goal,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.sessionsTotal == 0
        ? 0.0
        : goal.sessionsDone / goal.sessionsTotal;

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
              Text(goal.title, style: AppTextStyles.title),
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
              Text(
                '${goal.sessionsDone}/${goal.sessionsTotal} sessions',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ),
    );
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
