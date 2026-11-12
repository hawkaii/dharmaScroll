import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'design/theme.dart';

/// The root: theme, text scaling, router.
class DharmaScrollApp extends ConsumerWidget {
  const DharmaScrollApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'DharmaScroll',
      debugShowCheckedModeBanner: false,
      theme: DharmaTheme.night,
      darkTheme: DharmaTheme.night,
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
      builder: (BuildContext context, Widget? child) {
        // Respect the system font scale up to 1.3 (HANDOFF section 2).
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 1,
          maxScaleFactor: 1.3,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
