import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/practice/practice.dart';
import '../../core/rituals/providers.dart';
import '../../core/rituals/rituals.dart';
import '../../core/router.dart';
import '../../core/state/settings.dart';
import '../../design/info_sheet.dart';
import '../../design/lottie_art.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n.dart';
import '../../l10n/ritual_words.dart';
import 'practice_builder.dart';

String timeName(AppLocalizations l, int m) => fmtClock(l, m);

/// Your practice: what is on, what each one means, when the next note comes.
class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final AppLocalizations l = context.l;
    final Settings s = ref.watch(settingsProvider);
    final SettingsNotifier n = ref.read(settingsProvider.notifier);
    final PreviewContext? ctx = ref.watch(previewContextProvider);
    String? next({Set<Ritual> r = const <Ritual>{}, Deity d = Deity.none}) {
      if (ctx == null) return null;
      final PlannedReminder? p = firstNote(l, ctx, rituals: r, deity: d);
      return p == null ? null : l.nextNote(whenLabel(l, p.wall, ctx.now));
    }

    final List<Widget> items = <Widget>[
      for (final Ritual r in Ritual.values)
        if (s.rituals.contains(r))
          _Item(
            label: r == Ritual.dailyGita
                ? l.itemAtTime(l.ritualLabel(r), timeName(l, s.reminderMinutes))
                : l.ritualLabel(r),
            meaning: l.ritualMeaning(r),
            next: next(r: <Ritual>{r}),
            onTap: () => showInfo(
              context,
              title: l.ritualLabel(r),
              lines: <String>[
                l.ritualMeaning(r),
                ?next(r: <Ritual>{r}),
              ],
              art: _artFor(r),
              extra: r == Ritual.dailyGita
                  ? SecondaryButton(
                      label: l.changeHour,
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        _hourSheet(context, s.reminderMinutes, n.setReminder);
                      },
                    )
                  : SecondaryButton(
                      label: l.turnOff,
                      onPressed: () {
                        n.setRitual(r, on: false);
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
            ),
          ),
      if (s.deity != Deity.none)
        _Item(
          label: l.deityLabel(s.deity),
          meaning: l.deityMeaning(s.deity),
          next: next(d: s.deity),
          onTap: () => showInfo(
            context,
            title: l.deityLabel(s.deity),
            lines: <String>[
              l.deityMeaning(s.deity),
              ?next(d: s.deity),
            ],
            art: deityArt[s.deity],
            extra: SecondaryButton(
              label: l.turnOff,
              onPressed: () {
                n.setDeity(Deity.none);
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: c.bg,
      body: Backdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Sp.screenSide,
              Sp.s6,
              Sp.screenSide,
              Sp.s30,
            ),
            children: <Widget>[
              Row(
                children: <Widget>[
                  BackChevron(onTap: () => context.pop()),
                  Expanded(child: TopLine(left: l.tabYou)),
                ],
              ),
              const SizedBox(height: Sp.s12),
              Semantics(
                header: true,
                child: Text(
                  l.practiceTitle,
                  style: DType.title(c.ink, compact: true),
                ),
              ),
              const SizedBox(height: Sp.s6),
              Text(l.practiceIntro, style: DType.body(c.mute, size: 17)),
              const SizedBox(height: Sp.s18),
              if (items.isEmpty)
                Text(l.nothingOn, style: DType.body(c.mute))
              else
                ...items,
              const SizedBox(height: Sp.s22),
              PrimaryButton(
                label: l.practiceRebuild,
                onPressed: () => context.push(Routes.buildPractice),
              ),
              const SizedBox(height: Sp.s12),
              _Item(
                label: l.allReminders,
                meaning: l.allRemindersWhy,
                onTap: () => showDSheet<void>(
                  context,
                  (BuildContext ctx) => const AllRemindersSheet(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Art? _artFor(Ritual r) => switch (r) {
  Ritual.dailyGita => Art.lotusSafe,
  Ritual.sandhya => Art.citySun,
  Ritual.diya => Art.hourDiya,
  Ritual.ekadashi || Ritual.purnima || Ritual.amavasya => Art.moon,
  Ritual.pradosh => Art.trishul,
  Ritual.sankashti => Art.moon,
  Ritual.festivals => Art.twoPaths,
};

/// A small left chevron that goes back.
class BackChevron extends StatelessWidget {
  const BackChevron({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String label = context.l.back;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onTap();
        },
        // An arrow with its word: nobody has to guess what the arrow does.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.chevron_left, color: context.c.mute, size: 28),
              Text(label, style: DType.body(context.c.mute, size: 18)),
              const SizedBox(width: Sp.s6),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.label,
    required this.meaning,
    required this.onTap,
    this.next,
  });

  final String label;
  final String meaning;
  final String? next;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      button: true,
      label: <String>[label, meaning, ?next].join('. '),
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Sp.s14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.line)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: DType.body(c.ink, size: 21)),
                    Text(meaning, style: DType.body(c.mute, size: 15)),
                    if (next != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(next!.toUpperCase(), style: DType.ref(c.accent)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Sp.s12),
              Icon(Icons.chevron_right, size: 18, color: c.faint),
            ],
          ),
        ),
      ),
    );
  }
}

void _hourSheet(BuildContext context, int minutes, ValueChanged<int> set) {
  showDSheet<void>(
    context,
    (BuildContext ctx) => HourSheet(minutes: minutes, onChanged: set),
  );
}

/// The daily verse hour, on a slider.
class HourSheet extends StatefulWidget {
  const HourSheet({super.key, required this.minutes, required this.onChanged});

  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  State<HourSheet> createState() => _HourSheetState();
}

class _HourSheetState extends State<HourSheet> {
  late int _m = widget.minutes;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final AppLocalizations l = context.l;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(timeName(l, _m), style: DType.hero(c.verse, size: 56)),
        const SizedBox(height: Sp.s6),
        Text(l.hourSheetWhy, style: DType.body(c.mute, size: 16)),
        Semantics(
          label: l.verseHour,
          value: timeName(l, _m),
          child: Slider(
            min: 4 * 60,
            max: 22 * 60,
            divisions: (18 * 60) ~/ 15,
            value: _m.toDouble().clamp(4 * 60, 22 * 60),
            onChanged: (double v) {
              if (v.round() != _m) Haptics.tick();
              setState(() => _m = v.round());
              widget.onChanged(_m);
            },
          ),
        ),
      ],
    );
  }
}

/// One level deeper: every ritual switch, and the weekday lamp.
class AllRemindersSheet extends ConsumerWidget {
  const AllRemindersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final AppLocalizations l = context.l;
    final Settings s = ref.watch(settingsProvider);
    final SettingsNotifier n = ref.read(settingsProvider.notifier);
    void set(Ritual r, bool v) {
      n.setRitual(r, on: v);
      // The right moment: they just asked for a reminder.
      if (v) ref.read(reminderBackendProvider).requestPermission().ignore();
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Text(l.allReminders, style: DType.title(c.ink, compact: true)),
          const SizedBox(height: Sp.s12),
          for (final Ritual r in Ritual.values)
            Semantics(
              container: true,
              toggled: s.rituals.contains(r),
              label: l.ritualSemantic(l.ritualLabel(r), l.ritualMeaning(r)),
              excludeSemantics: true,
              onTap: () => set(r, !s.rituals.contains(r)),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Haptics.tick();
                  set(r, !s.rituals.contains(r));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: Sp.s12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: c.line)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l.ritualLabel(r),
                              style: DType.body(c.ink, size: 21),
                            ),
                            Text(
                              l.ritualMeaning(r),
                              style: DType.body(c.mute, size: 15),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: s.rituals.contains(r),
                        onChanged: (bool v) => set(r, v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: Sp.s18),
          Text(l.weekdayLamp, style: DType.body(c.mute, size: 17)),
          const SizedBox(height: Sp.s12),
          for (final Deity d in Deity.values) ...<Widget>[
            OptionRow(
              label: l.deityLabel(d),
              hint: d == Deity.none ? null : l.deityMeaning(d),
              selected: d == s.deity,
              onTap: () {
                n.setDeity(d);
                if (d != Deity.none) {
                  ref
                      .read(reminderBackendProvider)
                      .requestPermission()
                      .ignore();
                }
              },
            ),
            const SizedBox(height: Sp.s12),
          ],
        ],
      ),
    );
  }
}

/// "Build my practice" from You: full screen, saves on the last question.
class BuildPracticeScreen extends ConsumerWidget {
  const BuildPracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final Settings s = ref.read(settingsProvider);
    return Scaffold(
      backgroundColor: c.bg,
      body: Backdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Sp.screenSide,
              Sp.s18,
              Sp.screenSide,
              Sp.s12,
            ),
            child: PracticeBuilder(
              initial: PracticeAnswers.from(s),
              doneLabel: context.l.savePractice,
              onBack: () => context.pop(),
              onDone: (PracticePlan plan) {
                final PracticePlan p = applyPlan(
                  plan,
                  ref.read(settingsProvider).rituals,
                );
                ref
                    .read(settingsProvider.notifier)
                    .setPractice(p.rituals, p.deity);
                ref.read(reminderBackendProvider).requestPermission().ignore();
                context.pop();
              },
            ),
          ),
        ),
      ),
    );
  }
}
