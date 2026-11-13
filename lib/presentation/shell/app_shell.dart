import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../core/state/settings.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n.dart';

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

  /// The icon of each tab, in order. The words come from the translations.
  static const List<String> tabIcons = <String>['diya', 'path-stone', 'lotus'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = context.l;
    final List<String> labels = <String>[l.tabToday, l.tabYatra, l.tabYou];
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
                    for (int i = 0; i < tabIcons.length; i++)
                      Expanded(
                        child: _Tab(
                          label: labels[i],
                          icon: tabIcons[i],
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
        // 64 dp at least; taller when the words are big.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Sp.s6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DIcon(icon, size: 24, color: col, glow: active),
                const SizedBox(height: 4),
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: DType.sans,
                    fontFamilyFallback: const <String>[DType.serifDeva],
                    fontSize: 12.5,
                    letterSpacing: DType.indic ? 0 : 1.2,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: col,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
