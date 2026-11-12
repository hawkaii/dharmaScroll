import 'package:flutter/material.dart';

import '../theme/app_metrics.dart';
import '../theme/app_type.dart';
import '../theme/theme_x.dart';


/// An outlined pill used for onboarding intents, topics and check-in answers.
///
/// The visual height is 36 dp inside a 48 dp hit box, because a 36 dp chip is
/// comfortable and a 36 dp tap target is not.
class ChoiceChipTag extends StatelessWidget {
  const ChoiceChipTag({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Widget pill = AnimatedContainer(
      duration: AppMotion.resolve(context, AppMotion.fast),
      curve: AppMotion.enter,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s12 + 2,
        vertical: AppSpace.s8,
      ),
      decoration: BoxDecoration(
        color: selected ? context.colors.primary : context.colors.surface,
        border: Border.all(
          color: selected ? context.colors.primary : context.colors.border,
          width: AppBorder.hairline,
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(
              icon,
              size: 15,
              color: selected
                  ? context.colors.onPrimary
                  : context.colors.inkMuted,
            ),
            const SizedBox(width: AppSpace.s6),
          ],
          Flexible(
            child: Text(
              label,
              style: AppType.l1.copyWith(
                color: selected ? context.colors.onPrimary : context.colors.ink,
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.s6),
          child: SizedBox(
            height: 36,
            child: selected
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      boxShadow: AppShadow.soft,
                    ),
                    child: pill,
                  )
                : pill,
          ),
        ),
      ),
    );
  }
}
