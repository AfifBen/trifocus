import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../controllers/library_controller.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryProvider);

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
            _SectionCard(
              title: 'Projects',
              subtitle: '${state.projects.length} items',
              onTap: () => context.push('/library/projects'),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Habits',
              subtitle: '${state.habits.length} items',
              onTap: () => context.push('/library/habits'),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Paths',
              subtitle: '${state.paths.length} items',
              onTap: () => context.push('/library/paths'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SectionCard({required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
            Row(
              children: [
                Text(subtitle, style: AppTextStyles.body),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
