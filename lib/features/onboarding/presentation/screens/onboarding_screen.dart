import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../goals/presentation/controllers/today_goals_controller.dart';
import '../../../templates/domain/models/goal_template.dart';
import '../../../templates/presentation/controllers/templates_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider);

    final suggested = <GoalTemplate>[
      GoalTemplate(
        id: 'suggest_workday',
        name: 'Workday',
        createdAt: DateTime.now(),
        goals: const [],
      ),
      GoalTemplate(
        id: 'suggest_learning',
        name: 'Learning',
        createdAt: DateTime.now(),
        goals: const [],
      ),
      GoalTemplate(
        id: 'suggest_fitness',
        name: 'Fitness',
        createdAt: DateTime.now(),
        goals: const [],
      ),
    ];

    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text('TriFocus', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            const Text(
              'Choose three goals. Focus deeply. Build momentum.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick start', style: AppTextStyles.title),
                  const SizedBox(height: 8),
                  const Text(
                    'Apply a template or create your own 3 goals.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/create-goals'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Create my 3 goals'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showTemplatePicker(
                        context,
                        ref,
                        templates.isEmpty ? suggested : templates,
                        suggested: templates.isEmpty,
                      ),
                      child: const Text('Apply a template'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'Rule of 3 → Focus → Break → Repeat',
                    style: AppTextStyles.body,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTemplatePicker(
    BuildContext context,
    WidgetRef ref,
    List<GoalTemplate> templates, {
    required bool suggested,
  }) async {
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
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  suggested ? 'Suggested templates' : 'Your templates',
                  style: AppTextStyles.title,
                ),
              ),
              ...templates.map(
                (t) => ListTile(
                  title: Text(t.name, style: AppTextStyles.title),
                  subtitle: Text(
                    suggested
                        ? _suggestedPreview(t.id)
                        : t.goals.take(3).map((g) => g.title).join(' • '),
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

    if (suggested) {
      final goals = _suggestedGoals(selected);
      await ref.read(todayGoalsProvider.notifier).setGoals(goals);
    } else {
      final tpl = templates.firstWhere((t) => t.id == selected);
      await ref
          .read(todayGoalsProvider.notifier)
          .setGoals(tpl.goals.take(3).map((g) => g.copyWith(sessionsDone: 0)).toList());
    }

    if (!context.mounted) return;
    context.go('/today');
  }

  String _suggestedPreview(String id) {
    final goals = _suggestedGoals(id);
    return goals.take(3).map((g) => g.title).join(' • ');
  }

  List<Goal> _suggestedGoals(String id) {
    switch (id) {
      case 'suggest_learning':
        return const [
          Goal(
            id: 'goal_1',
            title: 'Read 20 pages',
            categoryType: 'habit',
            categoryItem: 'Reading',
            description: 'Deep reading session',
            sessionsTotal: 2,
          ),
          Goal(
            id: 'goal_2',
            title: 'Build TriFocus',
            categoryType: 'project',
            categoryItem: 'TriFocus',
            description: 'Ship one sprint',
            sessionsTotal: 4,
          ),
          Goal(
            id: 'goal_3',
            title: 'Review notes',
            categoryType: 'work',
            categoryItem: 'Planning',
            description: 'Summarize and plan tomorrow',
            sessionsTotal: 1,
          ),
        ];
      case 'suggest_fitness':
        return const [
          Goal(
            id: 'goal_1',
            title: 'Workout',
            categoryType: 'habit',
            categoryItem: 'Gym',
            description: 'Strength session',
            sessionsTotal: 1,
          ),
          Goal(
            id: 'goal_2',
            title: 'Walk 30 minutes',
            categoryType: 'habit',
            categoryItem: 'Health',
            description: 'Outdoor walk',
            sessionsTotal: 1,
          ),
          Goal(
            id: 'goal_3',
            title: 'Meal prep',
            categoryType: 'work',
            categoryItem: 'Nutrition',
            description: 'Plan + prep',
            sessionsTotal: 1,
          ),
        ];
      default:
        return const [
          Goal(
            id: 'goal_1',
            title: 'Deep work',
            categoryType: 'work',
            categoryItem: 'Main task',
            description: 'One important task',
            sessionsTotal: 3,
          ),
          Goal(
            id: 'goal_2',
            title: 'Admin',
            categoryType: 'work',
            categoryItem: 'Ops',
            description: 'Emails / errands',
            sessionsTotal: 1,
          ),
          Goal(
            id: 'goal_3',
            title: 'Learn',
            categoryType: 'habit',
            categoryItem: 'Skill',
            description: 'Study session',
            sessionsTotal: 1,
          ),
        ];
    }
  }
}
