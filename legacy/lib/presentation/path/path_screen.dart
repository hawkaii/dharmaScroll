import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/router/app_router.dart';
import '../../core/state/progress.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/mp_pill.dart';
import 'path_node.dart';

class PathScreen extends ConsumerStatefulWidget {
  const PathScreen({super.key});

  @override
  ConsumerState<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends ConsumerState<PathScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!reduceMotion && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final ProgressState progress = ref.watch(progressProvider);

    PathNodeState nodeState(int index) {
      if (index < progress.completedVerses) return PathNodeState.completed;
      if (index == progress.completedVerses) return PathNodeState.active;
      return PathNodeState.locked;
    }

    final units = <_Unit>[
      _Unit('Unit 1 · Karma', <_Node>[
        _Node('1', nodeState(0)),
        _Node('2', nodeState(1)),
        _Node('3', nodeState(2)),
        _Node('4', nodeState(3)),
      ]),
      _Unit('Unit 2 · Jnana', <_Node>[
        _Node('5', nodeState(4)),
        _Node('6', nodeState(5)),
      ]),
    ];

    return Scaffold(
      backgroundColor: colors.surfaceCanvas,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppSpace.s16),
              child: Row(
                children: <Widget>[
                  Lottie.asset(
                    'assets/lottie/diya_flame.json',
                    width: 28,
                    height: 28,
                    repeat: !reduceMotion,
                  ),
                  const SizedBox(width: AppSpace.s4),
                  _Badge(label: '${progress.streak}', color: colors.primary),
                  const Spacer(),
                  MpPill(points: progress.points, compact: true),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.settings, color: colors.ink),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Daily goal ${progress.cardsToday}/${progress.dailyGoal}',
                    style: AppType.m1.copyWith(color: colors.inkMuted),
                  ),
                  const SizedBox(height: AppSpace.s4),
                  LinearProgressIndicator(
                    value: progress.dailyFraction,
                    backgroundColor: colors.surfaceSunken,
                    color: colors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.s12),
            Expanded(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (BuildContext context, Widget? _) {
                  final double pulseScale = reduceMotion
                      ? 1.0
                      : Tween<double>(begin: 1.0, end: 1.08).evaluate(_pulse);
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpace.s16),
                    itemCount: units.length,
                    itemBuilder: (BuildContext context, int ui) {
                      final unit = units[ui];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpace.s12),
                            margin: const EdgeInsets.only(bottom: AppSpace.s12),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              unit.title,
                              style: AppType.t1.copyWith(color: colors.onPrimary),
                            ),
                          ),
                          ...unit.nodes.asMap().entries.map((MapEntry<int, _Node> e) {
                            final bool right = e.key.isOdd;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpace.s16),
                              child: Align(
                                alignment: right
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: e.value.state == PathNodeState.active
                                    ? Transform.scale(
                                        scale: pulseScale,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            Lottie.asset(
                                              'assets/lottie/chakra.json',
                                              width: 96,
                                              height: 96,
                                              repeat: !reduceMotion,
                                            ),
                                            PathNode(
                                              state: e.value.state,
                                              label: e.value.label,
                                              onTap: () => context.push(Routes.lesson),
                                            ),
                                          ],
                                        ),
                                      )
                                    : PathNode(
                                        state: e.value.state,
                                        label: e.value.label,
                                      ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Unit {
  _Unit(this.title, this.nodes);
  final String title;
  final List<_Node> nodes;
}

class _Node {
  _Node(this.label, this.state);
  final String label;
  final PathNodeState state;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s12, vertical: AppSpace.s6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppType.m1.copyWith(color: color)),
    );
  }
}