import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/state/progress.dart';
import '../../design/effects.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../kept/kept_screen.dart' show BackMark;

const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Today", "Yesterday" or "12 Nov".
String dayName(String key, DateTime now) {
  if (key == dayKey(now)) return 'Today';
  if (key == dayKey(now.subtract(const Duration(days: 1)))) return 'Yesterday';
  final List<String> p = key.split('-');
  if (p.length != 3) return key;
  return '${int.parse(p[2])} ${_months[int.parse(p[1]) - 1]}';
}

/// Moksh Points: the total and where each one came from. Nothing to buy.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static const String promise = 'They only go up.\nNothing here is for sale.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final ProgressState p = ref.watch(progressProvider);
    final DateTime now = ref.read(clockProvider)();
    final List<PointEntry> history = p.ledger.reversed.toList();
    return Scaffold(
      backgroundColor: c.bg,
      body: Backdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Sp.s14,
                  Sp.s6,
                  Sp.screenSide,
                  0,
                ),
                child: const Row(
                  children: <Widget>[
                    BackMark(),
                    Expanded(child: TopLine(left: 'Moksh Points')),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Sp.screenSide,
                    Sp.s22,
                    Sp.screenSide,
                    Sp.s30,
                  ),
                  children: <Widget>[
                    Center(
                      child: DIcon(
                        'peacock',
                        size: 44,
                        color: c.peacock,
                        glow: true,
                      ),
                    ),
                    const SizedBox(height: Sp.s12),
                    Center(
                      child: Semantics(
                        label: '${p.points} Moksh Points',
                        excludeSemantics: true,
                        child: CountUp(
                          value: p.points,
                          style: DType.hero(c.verse).copyWith(
                            shadows: <Shadow>[
                              Shadow(
                                color: Tok.flame.withValues(alpha: 0.45),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.s12),
                    Text(
                      promise,
                      textAlign: TextAlign.center,
                      style: DType.body(c.mute, size: 17),
                    ),
                    const SizedBox(height: Sp.s30),
                    Text('HOW THEY CAME', style: DType.eyebrow(c.accent)),
                    const SizedBox(height: Sp.s12),
                    if (history.isEmpty)
                      Text(
                        "Your first points come with today's five verses.",
                        style: DType.body(c.faint, size: 17),
                      ),
                    for (int i = 0; i < history.length; i++) ...<Widget>[
                      if (i == 0 || history[i].day != history[i - 1].day)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: Sp.s14,
                            bottom: Sp.s6,
                          ),
                          child: Text(
                            dayName(history[i].day, now).toUpperCase(),
                            style: DType.ref(c.faint),
                          ),
                        ),
                      PointsRow(
                        label:
                            ProgressNotifier.reasons[history[i].reason] ??
                            history[i].reason,
                        amount: history[i].amount,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One line: what you did, and the points it gave.
class PointsRow extends StatelessWidget {
  const PointsRow({
    super.key,
    required this.label,
    required this.amount,
    this.done = true,
  });

  final String label;
  final int amount;

  /// False: still waiting today; the amount shows faint.
  final bool done;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.line)),
      ),
      child: Row(
        children: <Widget>[
          DIcon(
            done ? 'check' : 'path-stone',
            size: 18,
            color: done ? c.accent : c.faint,
          ),
          const SizedBox(width: Sp.s12),
          Expanded(
            child: Text(
              label,
              style: DType.body(done ? c.ink : c.faint, size: 18),
            ),
          ),
          Semantics(
            label: done ? 'plus $amount' : '$amount waiting',
            excludeSemantics: true,
            child: Text(
              '+$amount',
              style: DType.button(done ? c.verse : c.faint),
            ),
          ),
        ],
      ),
    );
  }
}

/// The daily reward sheet: what today has given so far. Fixed amounts, no
/// chance, no chest.
Future<void> showTodayPointsSheet(BuildContext context, ProgressState p) {
  final Map<String, int> got = <String, int>{
    for (final PointEntry e in p.todayEntries) e.reason: e.amount,
  };
  const List<(String, int)> plan = <(String, int)>[
    ('hear', ProgressNotifier.hearPoints),
    ('walk', ProgressNotifier.walkPoints),
    ('speak', ProgressNotifier.speakPoints),
  ];
  final bool all = plan.every(((String, int) e) => got.containsKey(e.$1));
  final int total = got.values.fold(0, (int a, int b) => a + b);
  return showDSheet<void>(context, (BuildContext ctx) {
    final DharmaColors c = ctx.c;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("TODAY'S LIGHT", style: DType.eyebrow(c.accent)),
        const SizedBox(height: Sp.s6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            CountUp(value: total, style: DType.hero(c.verse, size: 56)),
            const SizedBox(width: Sp.s12),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Moksh Points today',
                style: DType.body(c.mute, size: 17),
              ),
            ),
          ],
        ),
        const SizedBox(height: Sp.s12),
        for (final (String reason, int amount) in plan)
          PointsRow(
            label: ProgressNotifier.reasons[reason]!,
            amount: got[reason] ?? amount,
            done: got.containsKey(reason),
          ),
        if (got.containsKey('sankalp'))
          PointsRow(
            label: ProgressNotifier.reasons['sankalp']!,
            amount: got['sankalp']!,
          ),
        const SizedBox(height: Sp.s18),
        Text(
          all
              ? 'No more points today. Just peace.'
              : 'Each step gives its points once a day.',
          style: DType.body(c.faint, size: 16),
        ),
      ],
    );
  });
}
