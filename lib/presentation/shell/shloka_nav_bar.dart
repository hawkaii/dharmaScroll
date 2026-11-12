import 'package:flutter/material.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';

/// Order matches the shell branches in `app_router.dart`.
enum ShlokaTab { today, yatra, you }

/// Three tabs: Today, Yatra, You. Mann Darpan and Sangha are reached from
/// Today, so the bar never grows past three.
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
                    width: AppBorder.hairline,
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
                    child: _NavItem(
                      tab: ShlokaTab.values[i],
                      active: currentIndex == i,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
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
    ShlokaTab.today => 'Today',
    ShlokaTab.yatra => 'Yatra',
    ShlokaTab.you => 'You',
  };

  static IconData _icon(ShlokaTab tab) => switch (tab) {
    ShlokaTab.today => Icons.wb_twilight_outlined,
    ShlokaTab.yatra => Icons.route_outlined,
    ShlokaTab.you => Icons.person_outline,
  };
}
