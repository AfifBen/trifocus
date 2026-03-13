import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

class QuickActionsService {
  static const _qa = QuickActions();

  static void init({
    required void Function(String) onAction,
  }) {
    _qa.initialize(onAction);
    _qa.setShortcutItems(const <ShortcutItem>[
      ShortcutItem(
        type: 'start_focus',
        localizedTitle: 'Start Focus',
        icon: 'ic_launcher',
      ),
      ShortcutItem(
        type: 'apply_template',
        localizedTitle: 'Apply Template',
        icon: 'ic_launcher',
      ),
    ]);
  }

  static String? routeForAction(String type) {
    return switch (type) {
      'start_focus' => '/focus',
      'apply_template' => '/today',
      _ => null,
    };
  }
}
