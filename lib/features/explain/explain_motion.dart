import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../design/tokens.dart';
import '../../design/widgets.dart';

/// One of the sheet's Lottie files (`assets/lottie/explain/`), drawn in
/// board v3 colours by `tools/explain_gen/lottie_gen.py`.
/// Reduce motion shows frame 0, which each file keeps as a finished still.
class ExplainLottie extends StatelessWidget {
  const ExplainLottie(this.name, {super.key, this.size, this.repeat = true});

  final String name;

  /// Square size for the small headers. Null fills the parent (the scene).
  final double? size;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Lottie.asset(
        'assets/lottie/explain/$name.json',
        width: size,
        height: size,
        fit: BoxFit.contain,
        animate: !reduceMotion(context),
        repeat: repeat,
      ),
    );
  }
}

/// Children rise 8 px and fade in, one after another, once.
class StaggeredReveal extends StatefulWidget {
  const StaggeredReveal({super.key, required this.children});

  final List<Widget> children;

  static const Duration each = Duration(milliseconds: 260);
  static const Duration stagger = Duration(milliseconds: 40);

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration:
        StaggeredReveal.each +
        StaggeredReveal.stagger * (widget.children.length - 1).clamp(0, 30),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double total = _c.duration!.inMilliseconds.toDouble();
    return Wrap(
      spacing: Sp.s12,
      runSpacing: Sp.s12,
      children: <Widget>[
        for (int i = 0; i < widget.children.length; i++)
          Builder(
            builder: (BuildContext context) {
              final double start =
                  (StaggeredReveal.stagger.inMilliseconds * i.clamp(0, 30)) /
                  total;
              final Animation<double> a = CurvedAnimation(
                parent: _c,
                curve: Interval(
                  start,
                  (start + StaggeredReveal.each.inMilliseconds / total).clamp(
                    0,
                    1,
                  ),
                  curve: Motion.easeOut,
                ),
              );
              return FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(a),
                  child: widget.children[i],
                ),
              );
            },
          ),
      ],
    );
  }
}
