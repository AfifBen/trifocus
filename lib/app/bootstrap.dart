import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

class AppBootstrap {
  static Widget buildApp() {
    return const ProviderScope(child: TriFocusApp());
  }
}
