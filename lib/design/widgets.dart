import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/feedback/haptic_service.dart';
import '../core/feedback/sound_service.dart';
import '../l10n/l10n.dart';
import 'tokens.dart';

/// Short names for the haptic patterns; see `HapticService` for the map.
/// The You > Sound & haptics switch sets [enabled].
abstract final class Haptics {
  static bool get enabled => HapticService.instance.enabled;
  static set enabled(bool v) => HapticService.instance.enabled = v;
  static void tap() => HapticService.instance.tap();
  static void tick() => HapticService.instance.tick();
  static void soft() => HapticService.instance.soft();
  static void pulse() => HapticService.instance.pulse();
  static void keep() => HapticService.instance.keep();
  static void success() => HapticService.instance.success();
  static void crescendo() => HapticService.instance.crescendo();
}

bool reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

/// Line icon from `assets/svg/icons`, recoloured at runtime.
class DIcon extends StatelessWidget {
  const DIcon(
    this.name, {
    super.key,
    this.size = 22,
    this.color,
    this.glow = false,
    this.label,
  });

  final String name;
  final double size;
  final Color? color;
  final bool glow;

  /// Spoken label. Null means decorative.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final Color col = color ?? context.c.accent;
    Widget icon(double opacity) => Opacity(
      opacity: opacity,
      child: SvgPicture.asset(
        'assets/svg/icons/$name.svg',
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(col, BlendMode.srcIn),
      ),
    );
    Widget child = glow
        ? Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: icon(0.55),
              ),
              icon(1),
            ],
          )
        : icon(1);
    child = SizedBox(width: size, height: size, child: child);
    return label == null
        ? ExcludeSemantics(child: child)
        : Semantics(label: label, image: true, child: child);
  }
}

/// Full-screen background: colour, top and bottom glow, faint mandala.
class Backdrop extends StatelessWidget {
  const Backdrop({super.key, required this.child, this.mandala = true});

  final Widget child;
  final bool mandala;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ColoredBox(color: c.bg),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -1.1),
              radius: 1.0,
              colors: <Color>[c.glowTop, c.glowTop.withValues(alpha: 0)],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 1.2),
              radius: 0.9,
              colors: <Color>[c.glowBottom, c.glowBottom.withValues(alpha: 0)],
            ),
          ),
        ),
        if (mandala)
          ExcludeSemantics(
            child: Align(
              alignment: const Alignment(0, -0.12),
              child: OverflowBox(
                maxWidth: 560,
                maxHeight: 560,
                child: Opacity(
                  opacity: c.mandalaOpacity,
                  child: SvgPicture.asset(
                    'assets/svg/mandala.svg',
                    width: 560,
                    height: 560,
                    colorFilter: ColorFilter.mode(
                      c.isLight ? c.accent : Tok.marigold,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}

/// The primary action: 56 px, gradient, 3 px edge, 2 px press-down.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
    this.voice = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  /// Peacock instead of marigold: the one voice action (board: "Done").
  final bool voice;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    final BorderRadius r = BorderRadius.circular(Rad.button);
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapCancel: () => _set(false),
        onTapUp: (_) => _set(false),
        onTap: enabled
            ? () {
                Haptics.tap();
                SoundService.instance.play(Sfx.tap);
                widget.onPressed!();
              }
            : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          // 56 dp tall at least, and taller when the words wrap (large text,
          // a long Hindi label): the face grows, the edge follows.
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                top: 3,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.voice ? Tok.voiceEdge : Tok.btnEdge,
                    borderRadius: r,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: (widget.voice ? Tok.voiceB : Tok.saffron)
                            .withValues(alpha: 0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedPadding(
                duration: Motion.press,
                curve: Motion.easeOut,
                padding: EdgeInsets.only(
                  top: _down ? 2 : 0,
                  bottom: _down ? 1 : 3,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: r,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: widget.voice
                            ? const <Color>[Tok.voiceA, Tok.voiceB]
                            : const <Color>[Tok.btnA, Tok.btnB],
                      ),
                      border: const Border(
                        top: BorderSide(color: Tok.btnHighlight),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sp.s18,
                        vertical: Sp.s12,
                      ),
                      child: Center(
                        child: Text(
                          widget.label,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: DType.button(
                            widget.voice ? Tok.voiceInk : Tok.btnInk,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A second choice beside the primary one: same size, outlined, no fill.
/// Pressed: sinks 2 px, like the primary.
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final bool enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapCancel: () => _set(false),
        onTapUp: (_) => _set(false),
        onTap: enabled
            ? () {
                Haptics.tap();
                SoundService.instance.play(Sfx.tap);
                widget.onPressed!();
              }
            : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: AnimatedPadding(
            duration: Motion.press,
            curve: Motion.easeOut,
            padding: EdgeInsets.only(top: _down ? 3 : 1, bottom: _down ? 0 : 2),
            child: AnimatedContainer(
              duration: Motion.press,
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(
                horizontal: Sp.s18,
                vertical: Sp.s12,
              ),
              decoration: BoxDecoration(
                color: _down ? c.raised : c.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(Rad.button),
                border: Border.all(
                  color: _down ? Tok.marigold : c.ink.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (widget.leading != null) ...<Widget>[
                    widget.leading!,
                    const SizedBox(width: Sp.s12),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: DType.button(c.ink),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quiet secondary action under a primary button.
class TextAction extends StatelessWidget {
  const TextAction({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onPressed();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: DType.body(context.c.mute, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

/// Card on the surface colour.
class DCard extends StatelessWidget {
  const DCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Container(
      padding: padding ?? const EdgeInsets.all(Sp.s18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Rad.card),
        border: Border.all(color: c.line),
      ),
      child: child,
    );
  }
}

/// Option row: 60 px, 18 radius. Selected = marigold border + 9% fill.
class OptionRow extends StatelessWidget {
  const OptionRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.hint,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// One plain line under the label: what this choice means.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      button: true,
      selected: selected,
      label: hint == null ? label : '$label. $hint',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onTap();
        },
        child: AnimatedContainer(
          duration: Motion.select,
          curve: Motion.easeOut,
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: Sp.s18, vertical: 10),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: selected ? Tok.marigold.withValues(alpha: 0.09) : null,
            borderRadius: BorderRadius.circular(Rad.row),
            border: Border.all(color: selected ? Tok.marigold : c.line),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: hint == null
                    ? Text(label, style: DType.body(c.ink, size: 20))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(label, style: DType.body(c.ink, size: 20)),
                          Text(hint!, style: DType.body(c.mute, size: 16)),
                        ],
                      ),
              ),
              // A tick as well as the colour, so the choice is clear.
              if (selected) ...<Widget>[
                const SizedBox(width: Sp.s12),
                DIcon('check', size: 22, color: c.accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Top line: small caps left and right.
class TopLine extends StatelessWidget {
  const TopLine({super.key, required this.left, this.right});

  final String left;
  final String? right;

  @override
  Widget build(BuildContext context) {
    final TextStyle s = DType.eyebrow(context.c.faint);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(child: Text(left.toUpperCase(), style: s)),
        if (right != null)
          Flexible(child: Text(right!.toUpperCase(), style: s)),
      ],
    );
  }
}

/// Dashes for "3 of 5". Filled dashes in marigold.
class ProgressDashes extends StatelessWidget {
  const ProgressDashes({super.key, required this.total, required this.filled});

  final int total;
  final int filled;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      label: context.l.progressOf(filled, total),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < total; i++)
            Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
              child: AnimatedContainer(
                duration: Motion.select,
                width: 26,
                height: 2.5,
                decoration: BoxDecoration(
                  color: i < filled ? Tok.marigold : c.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bottom sheet on the surface colour. Opens on the root navigator so the
/// tab bar never paints over it.
Future<T?> showDSheet<T>(BuildContext context, WidgetBuilder builder) {
  final DharmaColors c = context.c;
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    backgroundColor: c.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(Rad.button)),
    ),
    builder: (BuildContext ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Sp.screenSide,
          Sp.s18,
          Sp.screenSide,
          Sp.s22,
        ),
        child: builder(ctx),
      ),
    ),
  );
}
