import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../controllers/library_controller.dart';
import '../../domain/models/path.dart';

class PathsScreen extends ConsumerWidget {
  const PathsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryProvider);

    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paths', style: AppTextStyles.headline),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: state.paths.length,
                itemBuilder: (context, index) {
                  final item = state.paths[index];
                  return Dismissible(
                    key: ValueKey(item.id),
                    onDismissed: (_) =>
                        ref.read(libraryProvider.notifier).removePath(item.id),
                    child: ListTile(
                      title: Text(item.title),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _add(context, ref),
                child: const Text('Add Path'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Path'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Path name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty) return;

    await ref.read(libraryProvider.notifier).addPath(
          Path(
            id: 'path_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
          ),
        );
  }
}
