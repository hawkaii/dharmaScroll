import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../core/state/settings.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';

/// Appearance rule: Auto means Ivory Dawn on Today from 05:00 to 10:00.
final Provider<bool> todayIsLightProvider = Provider<bool>((Ref ref) {
  final Appearance a = ref.watch(
    settingsProvider.select((Settings s) => s.appearance),
  );
  return a == Appearance.auto &&
      DharmaTheme.isDawnHour(ref.read(clockProvider)());
});

/// Three tabs: Today, Yatra, You.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<(String, String)> tabs = <(String, String)>[
    ('Today', 'diya'),
    ('Yatra', 'path-stone'),
    ('You', 'lotus'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool light =
        navigationShell.currentIndex == 0 && ref.watch(todayIsLightProvider);
    return Theme(
      data: light ? DharmaTheme.dawn : DharmaTheme.night,
      child: Builder(
        builder: (BuildContext context) {
          final DharmaColors c = context.c;
          return Scaffold(
            backgroundColor: c.bg,
            body: navigationShell,
            bottomNavigationBar: DecoratedBox(
              decoration: BoxDecoration(
                color: c.bg,
                border: Border(top: BorderSide(color: c.line)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: <Widget>[
                    for (int i = 0; i < tabs.length; i++)
                      Expanded(
                        child: _Tab(
                          label: tabs[i].$1,
                          icon: tabs[i].$2,
                          active: i == navigationShell.currentIndex,
                          onTap: () => navigationShell.goBranch(
                            i,
                            initialLocation: i == navigationShell.currentIndex,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final Color col = active ? c.accent : c.faint;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!active) Haptics.tick();
          onTap();
        },
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DIcon(icon, size: 22, color: col, glow: active),
              const SizedBox(height: 5),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: DType.sans,
                  fontSize: 10,
                  letterSpacing: 1.6,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: col,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
