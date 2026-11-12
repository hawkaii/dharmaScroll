import 'package:flutter/material.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';

enum PathNodeState { locked, active, completed }

class PathNode extends StatelessWidget {
  const PathNode({
    super.key,
    required this.state,
    required this.label,
    this.onTap,
  });

  final PathNodeState state;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bool locked = state == PathNodeState.locked;
    final Color fill = switch (state) {
      PathNodeState.locked => colors.inkDisabled,
      PathNodeState.active => colors.primary,
      PathNodeState.completed => colors.gold,
    };
    final Widget icon = switch (state) {
      PathNodeState.locked => const Icon(Icons.lock, size: 16, color: Colors.white),
      PathNodeState.active => const Icon(Icons.play_arrow, size: 20, color: Colors.white),
      PathNodeState.completed => const Icon(Icons.check, size: 20, color: Colors.white),
    };

    return Semantics(
      button: !locked,
      label: label,
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                boxShadow: AppShadow.soft,
              ),
              child: Center(child: icon),
            ),
            const SizedBox(height: AppSpace.s4),
            Text(
              label,
              style: AppType.m1.copyWith(
                fontSize: 10,
                color: locked ? colors.inkDisabled : colors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
