import 'package:flutter/material.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/hard_shadow.dart';

enum ShlokaTab { shloka, yatra, mann, sangha, profile }

/// Five tabs with the mic raised through the middle.
///
/// Hand-rolled rather than `NavigationBar`: Material cannot raise one item, and
/// the raised mic is the signature of the shell.
class ShlokaNavBar extends StatelessWidget {
  const ShlokaNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _height = 64;

  @override
  Widget build(BuildContext context) {
    final double safeBottom = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: _height + safeBottom,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(
                  top: BorderSide(
                    color: context.colors.border,
                    width: AppBorder.b,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _height,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < ShlokaTab.values.length; i++)
                  Expanded(
                    child: i == 2
                        ? const SizedBox.shrink()
                        : _NavItem(
                            tab: ShlokaTab.values[i],
                            active: currentIndex == i,
                            onTap: () => onTap(i),
                          ),
                  ),
              ],
            ),
          ),
          // Last in the stack so it wins hit-testing over the row.
          Positioned(
            bottom: _height - 22,
            child: _MicButton(active: currentIndex == 2, onTap: () => onTap(2)),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final ShlokaTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tint = active
        ? context.colors.primary
        : context.colors.inkMuted;

    return Semantics(
      button: true,
      selected: active,
      label: _label(tab),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(_icon(tab), size: 21, color: tint),
              const SizedBox(height: 3),
              Text(
                _label(tab),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.m1.copyWith(
                  fontSize: 9,
                  letterSpacing: 0.3,
                  color: tint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _label(ShlokaTab tab) => switch (tab) {
    ShlokaTab.shloka => 'Shloka',
    ShlokaTab.yatra => 'Yatra',
    ShlokaTab.mann => 'Mann',
    ShlokaTab.sangha => 'Sangha',
    ShlokaTab.profile => 'Profile',
  };

  static IconData _icon(ShlokaTab tab) => switch (tab) {
    ShlokaTab.shloka => Icons.auto_stories_outlined,
    ShlokaTab.yatra => Icons.route_outlined,
    ShlokaTab.mann => Icons.mic_none,
    ShlokaTab.sangha => Icons.groups_outlined,
    ShlokaTab.profile => Icons.person_outline,
  };
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Mann Darpan. Open the mic.',
      child: GestureDetector(
        onTap: onTap,
        child: HardShadow(
          offset: AppShadow.s4,
          radius: 28,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: active ? context.colors.gold : context.colors.field,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.border,
                width: AppBorder.b,
              ),
            ),
            child: Icon(
              Icons.mic,
              size: 24,
              color: active ? context.colors.onGold : context.colors.gold,
            ),
          ),
        ),
      ),
    );
  }
}
