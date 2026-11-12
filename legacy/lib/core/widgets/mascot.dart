import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Mascot placeholder: a small diya flame (reuses breathing_orb Lottie).
/// Replace with a dedicated mascot Lottie once designed.
class Mascot extends StatelessWidget {
  const Mascot({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/lottie/breathing_orb.json',
      width: size,
      height: size,
      repeat: !MediaQuery.disableAnimationsOf(context),
    );
  }
}