import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../controllers/history_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(historyProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: AppColors.background,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: items.isEmpty
            ? const Center(
                child: Text('No sessions yet', style: AppTextStyles.body),
              )
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final log = items[index];
                  final mins = (log.durationSeconds / 60).round();
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.goalTitle ?? 'Focus session',
                                style: AppTextStyles.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(log.createdAt),
                                style: AppTextStyles.body,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('$mins min', style: AppTextStyles.title),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}
