import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Reusable premium loading indicator backed by the Lottie spinner asset.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/lottie/loading_spinner.json',
        width: size,
        height: size,
        repeat: true,
      ),
    );
  }
}