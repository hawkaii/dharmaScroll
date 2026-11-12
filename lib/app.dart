import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/feedback/sound_service.dart';
import 'core/rituals/providers.dart';
import 'core/router.dart';
import 'design/theme.dart';

/// The root: theme, text scaling, router.
class DharmaScrollApp extends ConsumerWidget {
  const DharmaScrollApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Refreshes the 30-day reminder window on open and on every change.
    ref.watch(reminderSyncProvider);
    return MaterialApp.router(
      title: 'DharmaScroll',
      debugShowCheckedModeBanner: false,
      theme: DharmaTheme.night,
      darkTheme: DharmaTheme.night,
      themeMode: ThemeMode.dark,
      // Mouse and trackpad drag the verse scroll too (Flutter web, desktop).
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      routerConfig: ref.watch(routerProvider),
      builder: (BuildContext context, Widget? child) {
        // Respect the system font scale up to 1.3 (HANDOFF section 2).
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 1,
          maxScaleFactor: 1.3,
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
