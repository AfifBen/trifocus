import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/goal.dart';
import '../controllers/today_goals_controller.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  final Goal goal;
  const GoalDetailScreen({super.key, required this.goal});

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  late final TextEditingController titleController;
  late final TextEditingController categoryController;
  late final TextEditingController descriptionController;
  late final TextEditingController totalController;
  late String categoryType;
  TimeOfDay? scheduledTime;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.goal.title);
    categoryController = TextEditingController(text: widget.goal.categoryItem);
    descriptionController = TextEditingController(text: widget.goal.description);
    totalController = TextEditingController(text: widget.goal.sessionsTotal.toString());
    categoryType = widget.goal.categoryType;
    if (widget.goal.scheduledMinutes != null) {
      final minutes = widget.goal.scheduledMinutes!;
      scheduledTime = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Goal Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.title, style: AppTextStyles.headline),
            const SizedBox(height: 8),
            Text(goal.description, style: AppTextStyles.body),
            const SizedBox(height: 24),
            Text('Edit', style: AppTextStyles.title),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration('Title'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: categoryType,
                    dropdownColor: AppColors.surface,
                    decoration: _inputDecoration('Category'),
                    items: const [
                      DropdownMenuItem(value: 'project', child: Text('Project')),
                      DropdownMenuItem(value: 'habit', child: Text('Habit')),
                      DropdownMenuItem(value: 'path', child: Text('Path')),
                      DropdownMenuItem(value: 'work', child: Text('Work')),
                    ],
                    onChanged: (value) => categoryType = value ?? 'project',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: categoryController,
                    style: const TextStyle(color: AppColors.textPrimary),
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
                    controller: descriptionController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDecoration('Description (optional)'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final category = categoryController.text.trim();
                    descriptionController.text =
                        _generateDescription(title, category, categoryType);
                  },
                  child: const Text('Generate'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration('Cycles'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: scheduledTime ?? const TimeOfDay(hour: 9, minute: 0),
                      );
                      if (picked == null) return;
                      setState(() => scheduledTime = picked);
                    },
                    child: Text(
                      scheduledTime == null
                          ? 'Set time'
                          : 'Time: ${scheduledTime!.hour.toString().padLeft(2, '0')}:${scheduledTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: scheduledTime == null
                      ? null
                      : () => setState(() => scheduledTime = null),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final newTitle = titleController.text.trim();
    if (newTitle.isEmpty) return;

    final total = int.tryParse(totalController.text.trim()) ?? widget.goal.sessionsTotal;
    final categoryRaw = categoryController.text.trim();
    final categoryItem = categoryRaw.isEmpty ? newTitle : categoryRaw;

    final minutes = scheduledTime == null
        ? null
        : (scheduledTime!.hour * 60 + scheduledTime!.minute);

    final updated = widget.goal.copyWith(
      title: newTitle,
      categoryType: categoryType,
      categoryItem: categoryItem,
      description: descriptionController.text.trim(),
      sessionsTotal: total,
      scheduledMinutes: minutes,
      clearScheduledMinutes: scheduledTime == null,
    );

    await ref.read(todayGoalsProvider.notifier).updateGoal(updated);
    Navigator.of(context).pop();
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
