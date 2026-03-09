import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class TriFocusApp extends StatelessWidget {
  const TriFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TriFocus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
