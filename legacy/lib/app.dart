import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// The root widget: themes, text scaling, and the router.
///
/// `main` stays a one-liner by design — every setup call attaches here, at the
/// one place every screen is reached from.
class DharmaScrollApp extends ConsumerWidget {
  const DharmaScrollApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'DharmaScroll',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        // The blueprint's accessibility floor: honour the user's text size up
        // to 200%, never below 100%.
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 1,
          maxScaleFactor: 2,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
