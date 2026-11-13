import 'package:flutter/gestures.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/feedback/sound_service.dart';
import 'core/rituals/providers.dart';
import 'core/router.dart';
import 'core/state/settings.dart';
import 'design/theme.dart';
import 'design/tokens.dart';
import 'l10n/app_localizations.dart';

/// The most the words may grow: the person's pick or the system size,
/// whichever is bigger. Layouts are tested up to this.
const double maxTextScale = 1.4;

/// The root: theme, language, text size, router.
class DharmaScrollApp extends ConsumerWidget {
  const DharmaScrollApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Refreshes the 30-day reminder window on open and on every change.
    ref.watch(reminderSyncProvider);
    final Settings settings = ref.watch(settingsProvider);
    final bool hindi = settings.language == Language.hindi;
    DType.indic = hindi;
    return MaterialApp.router(
      title: 'DharmaScroll',
      debugShowCheckedModeBanner: false,
      // Hinglish is kept for old saves; the app's own words are English then.
      locale: Locale(hindi ? 'hi' : 'en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: DharmaTheme.night,
      darkTheme: DharmaTheme.night,
      themeMode: ThemeMode.dark,
      // Mouse and trackpad drag the verse scroll too (Flutter web, desktop).
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      routerConfig: ref.watch(routerProvider),
      builder: (BuildContext context, Widget? child) {
        // The person's text size and the system size: the bigger one wins,
        // never past [maxTextScale].
        final double system = MediaQuery.textScalerOf(context).scale(1);
        final double scale = math
            .max(settings.textSize.factor, system)
            .clamp(1, maxTextScale)
            .toDouble();
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: scale,
          maxScaleFactor: scale,
          // Browsers block audio until a gesture; the first touch unlocks it.
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => SoundService.instance.unlock(),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
