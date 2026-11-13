import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'widgets.dart';

/// The small explainer animations in `assets/lottie/`, written by
/// `tools/lottie_gen/gen.py` in the board v3 colours.
///
/// [loopFrom] and [still] are fractions of the file: it plays once, then loops
/// from [loopFrom] (the settled part, so lines do not redraw). With reduce
/// motion on, it shows the [still] frame and does not move.
enum Art {
  hourDiya('hour_diya', 1, loopFrom: 0.333, still: 0.333),
  twoPaths('two_paths', 1.25, loopFrom: 0.417, still: 0.417),
  citySun('city_sun', 200 / 140, loopFrom: 0.542, still: 0.542),
  lotusSafe('lotus_safe', 1, loopFrom: 0.375, still: 0.375),
  trishul('trishul', 1, loopFrom: 0.458, still: 0.458),
  gada('gada', 1, loopFrom: 0.417, still: 0.417),
  chakra('chakra', 1, loopFrom: 0.143, still: 0.143),
  shaniLamp('shani_lamp', 1, loopFrom: 0.483, still: 0.483),
  moon('moon', 1, still: 0.4),
  bell('bell', 1, still: 0.12),
  ripple('ripple', 1, still: 0.3),
  ekadashiTimeline('ekadashi_timeline', 2, still: 0.85);

  const Art(this.file, this.aspect, {this.loopFrom = 0, required this.still});

  final String file;

  /// Width over height.
  final double aspect;
  final double loopFrom;
  final double still;

  String get asset => 'assets/lottie/$file.json';
}

/// Plays an [Art]: once in, then a calm loop. Still under reduce motion.
class DLottie extends StatefulWidget {
  const DLottie(this.art, {super.key, this.height = 96, this.label});

  final Art art;
  final double height;

  /// Spoken label. Null means decorative.
  final String? label;

  @override
  State<DLottie> createState() => _DLottieState();
}

class _DLottieState extends State<DLottie> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  bool _loaded = false;

  void _start() {
    if (!_loaded || !mounted) return;
    final Art a = widget.art;
    if (reduceMotion(context)) {
      _c
        ..stop()
        ..value = a.still;
      return;
    }
    if (_c.isAnimating) return;
    _c.forward(from: 0).whenComplete(() {
      if (mounted && !reduceMotion(context)) {
        _c.repeat(min: a.loopFrom, max: 1);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _start();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget art = SizedBox(
      height: widget.height,
      width: widget.height * widget.art.aspect,
      child: Lottie.asset(
        widget.art.asset,
        controller: _c,
        fit: BoxFit.contain,
        onLoaded: (LottieComposition comp) {
          _c.duration = comp.duration;
          _loaded = true;
          _start();
        },
      ),
    );
    return widget.label == null
        ? ExcludeSemantics(child: art)
        : Semantics(label: widget.label, image: true, child: art);
  }
}
