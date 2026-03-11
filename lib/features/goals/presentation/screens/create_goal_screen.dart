import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/goal.dart';
import '../../../library/presentation/controllers/library_controller.dart';
import '../controllers/today_goals_controller.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final titleControllers = List.generate(3, (_) => TextEditingController());
  final totalControllers = List.generate(3, (_) => TextEditingController(text: '4'));
  final categoryControllers = List.generate(3, (_) => TextEditingController());
  final descriptionControllers = List.generate(3, (_) => TextEditingController());
  final categories = List.generate(3, (_) => 'project');
  final selectedItems = List<String?>.generate(3, (_) => null);

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Goals')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Objective ${index + 1}', style: AppTextStyles.title),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleControllers[index],
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Title'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: categories[index],
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            decoration: _inputDecoration('Category'),
                            items: const [
                              DropdownMenuItem(value: 'project', child: Text('Project')),
                              DropdownMenuItem(value: 'habit', child: Text('Habit')),
                              DropdownMenuItem(value: 'path', child: Text('Path')),
                              DropdownMenuItem(value: 'work', child: Text('Work')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                categories[index] = value ?? 'project';
                                selectedItems[index] = null;
                                categoryControllers[index].text = '';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _CategoryItemField(
                            type: categories[index],
                            value: selectedItems[index],
                            projects: library.projects.map((e) => e.title).toList(),
                            habits: library.habits.map((e) => e.title).toList(),
                            paths: library.paths.map((e) => e.title).toList(),
                            controller: categoryControllers[index],
                            onChanged: (v) {
                              setState(() {
                                selectedItems[index] = v;
                                categoryControllers[index].text = v ?? '';
                              });
                            },
                            onAddTap: () {
                              final route = switch (categories[index]) {
                                'project' => '/library/projects',
                                'habit' => '/library/habits',
                                'path' => '/library/paths',
                                _ => '/library',
                              };
                              context.push(route);
                            },
                            decoration: _inputDecoration('Category item'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: descriptionControllers[index],
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: _inputDecoration('Description (optional)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            final title = titleControllers[index].text.trim();
                            final category = categoryControllers[index].text.trim();
                            descriptionControllers[index].text =
                                _generateDescription(title, category, categories[index]);
                          },
                          child: const Text('Generate'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: totalControllers[index],
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Cycles'),
                    ),
                  ],
                ),
              ),
            );
          })
            ..add(
              const SizedBox(height: 8),
            )
            ..add(
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveGoals,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ),
        ),
      ),
    );
  }

  Future<void> _saveGoals() async {
    final rows = List.generate(3, (index) {
      return {
        'title': titleControllers[index].text.trim(),
        'total': int.tryParse(totalControllers[index].text.trim()) ?? 4,
        'categoryType': categories[index],
        'categoryItem': categoryControllers[index].text.trim(),
        'description': descriptionControllers[index].text.trim(),
      };
    }).where((row) => (row['title'] as String).isNotEmpty).toList();

    if (rows.isEmpty) return;

    final goals = List.generate(rows.length, (index) {
      final row = rows[index];
      final title = row['title'] as String;
      final categoryItemRaw = row['categoryItem'] as String;
      return Goal(
        id: 'goal_${index + 1}',
        title: title,
        categoryType: row['categoryType'] as String,
        categoryItem: categoryItemRaw.isEmpty ? title : categoryItemRaw,
        description: row['description'] as String,
        sessionsDone: 0,
        sessionsTotal: row['total'] as int,
      );
    });

    await ref.read(todayGoalsProvider.notifier).setGoals(goals);
    if (mounted) Navigator.of(context).pop();
  }

  String _generateDescription(String title, String category, String type) {
    final item = category.isNotEmpty ? category : title;
    switch (type) {
      case 'project':
        return 'Advance the project: $item';
      case 'habit':
        return 'Maintain the habit: $item';
      case 'path':
        return 'Progress in the path: $item';
      default:
        return 'Move the work forward: $item';
    }
  }

  InputDecoration _inputDecoration(String hint) {
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

class _CategoryItemField extends StatelessWidget {
  final String type;
  final String? value;
  final List<String> projects;
  final List<String> habits;
  final List<String> paths;
  final TextEditingController controller;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAddTap;
  final InputDecoration decoration;

  const _CategoryItemField({
    required this.type,
    required this.value,
    required this.projects,
    required this.habits,
    required this.paths,
    required this.controller,
    required this.onChanged,
    required this.onAddTap,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final items = switch (type) {
      'project' => projects,
      'habit' => habits,
      'path' => paths,
      _ => const <String>[],
    };

    if (type == 'work') {
      return TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: decoration,
      );
    }

    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Empty', style: AppTextStyles.body),
          const SizedBox(height: 6),
          OutlinedButton(
            onPressed: onAddTap,
            child: const Text('Add in Library'),
          ),
        ],
      );
    }

    final effectiveValue = (value != null && items.contains(value)) ? value : null;

    return DropdownButtonFormField<String>(
      value: effectiveValue,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      decoration: decoration,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
