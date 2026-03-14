import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../controllers/stats_controller.dart';
import '../controllers/stats_derived_controller.dart';

class StatsShellScreen extends ConsumerStatefulWidget {
  const StatsShellScreen({super.key});

  @override
  ConsumerState<StatsShellScreen> createState() => _StatsShellScreenState();
}

class _StatsShellScreenState extends ConsumerState<StatsShellScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);

    // Ensure history is loaded so derived stats are available immediately.
    Future.microtask(() {
      if (mounted) {
        ref.read(historyProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final derived = ref.watch(derivedStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Stats'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: () => context.push('/achievements'),
            icon: const Icon(Icons.emoji_events, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                _StatCard(title: 'Total sessions', value: '${derived.totalSessions}'),
                const SizedBox(height: 12),
                _StatCard(title: 'Focus today', value: '${derived.minutesToday} min'),
                const SizedBox(height: 12),
                _StatCard(title: 'Focus this week', value: '${derived.minutesThisWeek} min'),
                const SizedBox(height: 12),
                _StatCard(title: 'Streak', value: '${stats.streakDays} days'),
              ],
            ),
          ),
          const AnalyticsScreen(),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

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
          Text(title, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.title),
        ],
      ),
    );
  }
}
