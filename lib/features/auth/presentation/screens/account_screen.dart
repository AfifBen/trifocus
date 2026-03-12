import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../controllers/auth_controller.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: AppColors.background,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              return const Center(
                child: Text('Not signed in', style: AppTextStyles.body),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Signed in', style: AppTextStyles.headline),
                const SizedBox(height: 8),
                Text(user.email ?? user.uid, style: AppTextStyles.body),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => ref.read(authControllerProvider).signOut(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                    ),
                    child: const Text('Sign out'),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Text('Auth error: $e', style: AppTextStyles.body),
          ),
        ),
      ),
    );
  }
}
