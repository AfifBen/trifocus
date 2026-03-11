import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/today/presentation/screens/today_screen.dart';
import '../features/focus_session/presentation/screens/focus_screen.dart';
import '../features/focus_session/presentation/screens/break_screen.dart';
import '../features/focus_session/presentation/screens/session_complete_screen.dart';
import '../features/progress/presentation/screens/progress_screen.dart';
import '../features/stats/presentation/screens/stats_screen.dart';
import '../features/library/presentation/screens/library_screen.dart';
import '../features/library/presentation/screens/projects_screen.dart';
import '../features/library/presentation/screens/habits_screen.dart';
import '../features/library/presentation/screens/paths_screen.dart';
import '../shared/widgets/app_bottom_nav.dart';

final appRouter = GoRouter(
  initialLocation: '/today',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.toString();
        final index = switch (location) {
          '/focus' => 1,
          '/progress' => 2,
          '/library' => 3,
          '/stats' => 4,
          _ => 0,
        };
        return Scaffold(
          body: child,
          bottomNavigationBar: AppBottomNav(
            currentIndex: index,
            onTap: (selected) {
              final route = switch (selected) {
                1 => '/focus',
                2 => '/progress',
                3 => '/library',
                4 => '/stats',
                _ => '/today',
              };
              if (route != location) {
                context.go(route);
              }
            },
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/today',
          builder: (context, state) => const TodayScreen(),
        ),
        GoRoute(
          path: '/focus',
          builder: (context, state) => const FocusScreen(),
        ),
        GoRoute(
          path: '/break',
          builder: (context, state) => const BreakScreen(),
        ),
        GoRoute(
          path: '/session-complete',
          builder: (context, state) => const SessionCompleteScreen(),
        ),
        GoRoute(
          path: '/progress',
          builder: (context, state) => const ProgressScreen(),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) => const LibraryScreen(),
        ),
        GoRoute(
          path: '/library/projects',
          builder: (context, state) => const ProjectsScreen(),
        ),
        GoRoute(
          path: '/library/habits',
          builder: (context, state) => const HabitsScreen(),
        ),
        GoRoute(
          path: '/library/paths',
          builder: (context, state) => const PathsScreen(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsScreen(),
        ),
      ],
    ),
  ],
);
