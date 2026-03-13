import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/local_storage.dart';
import '../../../sync/cloud_sync_controller.dart';

final localeProvider = StateNotifierProvider<LocaleController, Locale?>(
  (ref) => LocaleController(ref)..load(),
);

class LocaleController extends StateNotifier<Locale?> {
  final Ref _ref;
  LocaleController(this._ref) : super(null);

  Future<void> load() async {
    final code = await LocalStorage.loadLocaleCode();
    if (code == null || code.isEmpty) {
      state = null;
      return;
    }
    state = Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    await LocalStorage.saveLocaleCode(locale?.languageCode);
    await _ref.read(cloudSyncProvider.notifier).pushIfSignedIn();
  }
}
