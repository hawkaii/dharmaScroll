import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import '../theme/app_type.dart';
import '../theme/theme_x.dart';

enum HardButtonVariant { primary, secondary, gold, danger, ghost }

/// Premium button: filled accent, soft shadow, scale-on-press.
class HardButton extends StatefulWidget {
  const HardButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = HardButtonVariant.primary,
    this.icon,
    this.compact = false,
    this.block = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final HardButtonVariant variant;
  final IconData? icon;
  final bool compact;
  final bool block;

  @override
  State<HardButton> createState() => _HardButtonState();
}

class _HardButtonState extends State<HardButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool enabled = widget.onPressed != null;

    final Color fill = widget.variant == HardButtonVariant.ghost
        ? Colors.transparent
        : switch (widget.variant) {
            HardButtonVariant.primary => c.primary,
            HardButtonVariant.secondary => c.surface,
            HardButtonVariant.gold => c.gold,
            HardButtonVariant.danger => c.danger,
            HardButtonVariant.ghost => Colors.transparent,
          };

    final Color labelColor = !enabled
        ? c.inkDisabled
        : switch (widget.variant) {
            HardButtonVariant.primary => c.onPrimary,
            HardButtonVariant.secondary => c.ink,
            HardButtonVariant.gold => c.onGold,
            HardButtonVariant.danger => const Color(0xFFFFF6EE),
            HardButtonVariant.ghost => c.ink,
          };

    final Color borderColor = widget.variant == HardButtonVariant.secondary
        ? c.border
        : Colors.transparent;

    final Widget face = AnimatedScale(
      scale: _down ? 0.98 : 1.0,
      duration: AppMotion.resolve(context, AppMotion.instant),
      curve: AppMotion.enter,
      child: AnimatedContainer(
        duration: AppMotion.resolve(context, AppMotion.fast),
        curve: AppMotion.enter,
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? AppSpace.s12 : AppSpace.s20,
          vertical: widget.compact ? AppSpace.s8 : AppSpace.s12,
        ),
        decoration: BoxDecoration(
          color: enabled ? fill : c.surfaceSunken,
          border: Border.all(color: borderColor, width: AppBorder.input),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: widget.variant == HardButtonVariant.ghost
              ? null
              : AppShadow.soft,
        ),
        child: Row(
          mainAxisSize: widget.block ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.icon != null) ...<Widget>[
              Icon(widget.icon, size: 18, color: labelColor),
              const SizedBox(width: AppSpace.s8),
            ],
            Flexible(
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: AppType.l1.copyWith(
                  color: labelColor,
                  fontSize: widget.compact ? 12 : 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                widget.onPressed!.call();
              }
            : null,
        child: widget.block
            ? SizedBox(width: double.infinity, child: face)
            : face,
      ),
    );
  }
}