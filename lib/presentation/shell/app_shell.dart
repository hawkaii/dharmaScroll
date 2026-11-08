import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shloka_nav_bar.dart';

/// Hosts the five branches so each tab keeps its own navigator and scroll state.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ShlokaNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
