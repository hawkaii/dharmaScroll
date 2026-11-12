import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'app_providers.dart';
import 'core/feedback/sound_service.dart';

/// Prefs are read once, before the first frame, because the router needs to
/// know whether onboarding is done synchronously. Three milliseconds here buys
/// a flash-free start.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Not awaited: sound must never hold up the first frame. On web it only
  // loads after the first tap.
  SoundService.instance.attach(AudioplayersBackend());

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const DharmaScrollApp(),
    ),
  );
}
