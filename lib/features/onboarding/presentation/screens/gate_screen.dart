import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/local_storage.dart';
import 'onboarding_screen.dart';

class GateScreen extends StatefulWidget {
  const GateScreen({super.key});

  @override
  State<GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends State<GateScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LocalStorage.loadGoals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final goals = snapshot.data ?? const [];
        if (goals.isNotEmpty) {
          if (!_navigated) {
            _navigated = true;
            Future.microtask(() {
              if (context.mounted) context.go('/today');
            });
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const OnboardingScreen();
      },
    );
  }
}
