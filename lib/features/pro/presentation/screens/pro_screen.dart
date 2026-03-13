import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('TriFocus Pro'),
        backgroundColor: AppColors.background,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TriFocus Pro', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            const Text(
              'Placeholder screen for future monetization. No payments are implemented yet.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 24),
            _Feature('Cloud sync across devices'),
            _Feature('Advanced analytics'),
            _Feature('Widgets & shortcuts'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                ),
                child: const Text('Close'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final String title;
  const _Feature(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.star, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
