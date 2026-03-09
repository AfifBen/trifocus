import 'package:flutter/material.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Stats', style: AppTextStyles.headline),
            SizedBox(height: 8),
            Text('Stats placeholder', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
