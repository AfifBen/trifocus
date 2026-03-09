import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: AppColors.surfaceAlt,
      indicatorColor: AppColors.primary.withOpacity(0.15),
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
        NavigationDestination(icon: Icon(Icons.timer), label: 'Focus'),
        NavigationDestination(icon: Icon(Icons.auto_graph), label: 'Progress'),
        NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
      ],
    );
  }
}
