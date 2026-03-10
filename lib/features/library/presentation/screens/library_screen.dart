import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Library', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            const Text('Projects, habits, and paths.', style: AppTextStyles.body),
            const SizedBox(height: 24),
            _SectionCard(title: 'Projects', subtitle: 'No projects yet'),
            const SizedBox(height: 12),
            _SectionCard(title: 'Habits', subtitle: 'No habits yet'),
            const SizedBox(height: 12),
            _SectionCard(title: 'Paths', subtitle: 'No paths yet'),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.title),
          Text(subtitle, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
