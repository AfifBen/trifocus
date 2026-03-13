import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/sync/quick_actions_service.dart';
import 'app.dart';
import 'router.dart';

class AppBootstrap {
  static Widget buildApp() {
    return ProviderScope(
      child: Builder(
        builder: (context) {
          QuickActionsService.init(
            onAction: (type) {
              final route = QuickActionsService.routeForAction(type);
              if (route == null) return;
              appRouter.go(route);
            },
          );
          return const TriFocusApp();
        },
      ),
    );
  }
}
