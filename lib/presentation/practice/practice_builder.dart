import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/practice/practice.dart';
import '../../core/rituals/rituals.dart';
import '../../design/lottie_art.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';

/// The deity-day cards: a symbol each, never a figure.
const Map<Deity, Art> deityArt = <Deity, Art>{
  Deity.shiva: Art.trishul,
  Deity.hanuman: Art.gada,
  Deity.vishnu: Art.chakra,
  Deity.shani: Art.shaniLamp,
};

const Map<Deity, (String, String)> deityCard = <Deity, (String, String)>{
  Deity.shiva: ('Monday', 'Shiva'),
  Deity.hanuman: ('Tuesday', 'Hanuman'),
  Deity.vishnu: ('Thursday', 'Vishnu, Guru'),
  Deity.shani: ('Saturday', 'Shani'),
};

/// "Build my practice": five warm questions, one at a time. Each yes shows
/// the first reminder it would really send. [onDone] gets the plan.
class PracticeBuilder extends ConsumerStatefulWidget {
  const PracticeBuilder({
    super.key,
    required this.initial,
    required this.onDone,
    required this.doneLabel,
    this.onBack,
    this.busy = false,
  });

  static const String next = 'Continue';
  static const List<String> titles = <String>[
    'Do you keep\na fast?',
    'Which day\nfeels like yours?',
    'Do you light\na lamp at dusk?',
    'A quiet minute\nat sunrise?',
    'The full moon\nand big days?',
  ];

  final PracticeAnswers initial;
  final ValueChanged<PracticePlan> onDone;
  final String doneLabel;

  /// Back from the first question. Null hides it there.
  final VoidCallback? onBack;

  /// True while the caller is finishing (the lamp is lighting).
  final bool busy;

  @override
  ConsumerState<PracticeBuilder> createState() => _PracticeBuilderState();
}

class _PracticeBuilderState extends ConsumerState<PracticeBuilder> {
  late PracticeAnswers _a = widget.initial;
  int _q = 0;

  void _next() {
    if (_q < PracticeBuilder.titles.length - 1) {
      setState(() => _q++);
      return;
    }
    widget.onDone(ref.read(practiceSuggesterProvider).suggest(_a));
  }

  void _back() {
    if (_q == 0) {
      widget.onBack?.call();
    } else {
      setState(() => _q--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final bool last = _q == PracticeBuilder.titles.length - 1;
    final (Art? art, String why, Widget answers, Widget? preview) = _question();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Motion.snap,
                      switchInCurve: Motion.easeOut,
                      child: Column(
                        key: ValueKey<int>(_q),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // The day cards carry their own symbols.
                          if (art != null) ...<Widget>[
                            DLottie(art, key: ValueKey<Art>(art), height: 96),
                            const SizedBox(height: Sp.s14),
                          ],
                          Text(
                            'YOUR PRACTICE  ·  ${_q + 1} OF ${PracticeBuilder.titles.length}',
                            style: DType.eyebrow(c.accent),
                          ),
                          const SizedBox(height: Sp.s12),
                          Semantics(
                            header: true,
                            child: Text(
                              PracticeBuilder.titles[_q],
                              textAlign: TextAlign.center,
                              style: DType.title(c.ink, compact: true),
                            ),
                          ),
                          const SizedBox(height: Sp.s12),
                          Text(
                            why,
                            textAlign: TextAlign.center,
                            style: DType.body(c.mute, size: 17),
                          ),
                          const SizedBox(height: Sp.s22),
                          answers,
                          AnimatedSize(
                            duration: Motion.select,
                            curve: Motion.easeOut,
                            child: preview ?? const SizedBox(width: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Sp.s18),
                  PrimaryButton(
                    label: last ? widget.doneLabel : PracticeBuilder.next,
                    onPressed: widget.busy ? null : _next,
                  ),
                  if (_q > 0 || widget.onBack != null)
                    TextAction(label: 'Back', onPressed: _back)
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  (Art?, String, Widget, Widget?) _question() {
    Widget yesNo(bool v, String yes, ValueChanged<bool> set) => Column(
      children: <Widget>[
        OptionRow(
          label: yes,
          selected: v,
          onTap: () => setState(() => set(true)),
        ),
        const SizedBox(height: Sp.s12),
        OptionRow(
          label: 'Not now',
          selected: !v,
          onTap: () => setState(() => set(false)),
        ),
      ],
    );
    return switch (_q) {
      0 => (
        Art.moon,
        'Ekadashi is the eleventh day of the moon. It comes twice a month. '
            'Many people fast on it.',
        yesNo(
          _a.fast,
          'Yes, on Ekadashi',
          (bool v) => _a = _a.copyWith(fast: v),
        ),
        _a.fast ? _Preview(rituals: const <Ritual>{Ritual.ekadashi}) : null,
      ),
      1 => (
        null,
        'Many homes keep one day of the week for one god. Pick one, or none.',
        _DayCards(
          selected: _a.day,
          onSelected: (Deity d) => setState(() => _a = _a.copyWith(day: d)),
        ),
        _a.day == Deity.none ? null : _Preview(deity: _a.day),
      ),
      2 => (
        Art.hourDiya,
        'Dusk is when day turns into night. A small lamp then is an old way '
            'to say thank you.',
        yesNo(
          _a.duskLamp,
          'Yes, most evenings',
          (bool v) => _a = _a.copyWith(duskLamp: v),
        ),
        _a.duskLamp ? _Preview(rituals: const <Ritual>{Ritual.diya}) : null,
      ),
      3 => (
        Art.citySun,
        'Sandhya means the meeting of night and day. One still minute as '
            'the sun comes up.',
        yesNo(
          _a.sunrise,
          'Yes, please',
          (bool v) => _a = _a.copyWith(sunrise: v),
        ),
        _a.sunrise ? _Preview(rituals: const <Ritual>{Ritual.sandhya}) : null,
      ),
      _ => (
        Art.moon,
        'Purnima is the full moon. Amavasya is the night with no moon. '
            'Big days like Diwali fall on them.',
        yesNo(
          _a.moonDays,
          'Yes, tell me',
          (bool v) => _a = _a.copyWith(moonDays: v),
        ),
        _a.moonDays
            ? _Preview(
                rituals: const <Ritual>{
                  Ritual.purnima,
                  Ritual.amavasya,
                  Ritual.festivals,
                },
              )
            : null,
      ),
    };
  }
}

/// Four symbol cards and "No day for now".
class _DayCards extends StatelessWidget {
  const _DayCards({required this.selected, required this.onSelected});

  final Deity selected;
  final ValueChanged<Deity> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget card(Deity d) {
      final DharmaColors c = context.c;
      final bool on = d == selected;
      final (String day, String god) = deityCard[d]!;
      return Expanded(
        child: Semantics(
          button: true,
          selected: on,
          label: '$day, $god',
          excludeSemantics: true,
          onTap: () => onSelected(d),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Haptics.tick();
              onSelected(d);
            },
            child: AnimatedContainer(
              duration: Motion.select,
              curve: Motion.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: on ? Tok.marigold.withValues(alpha: 0.09) : null,
                borderRadius: BorderRadius.circular(Rad.row),
                border: Border.all(color: on ? Tok.marigold : c.line),
              ),
              child: Column(
                children: <Widget>[
                  Opacity(
                    opacity: on ? 1 : 0.7,
                    child: DLottie(deityArt[d]!, height: 48),
                  ),
                  const SizedBox(height: Sp.s6),
                  Text(day, style: DType.body(c.ink, size: 18)),
                  Text(god.toUpperCase(), style: DType.ref(c.faint)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            card(Deity.shiva),
            const SizedBox(width: Sp.s12),
            card(Deity.hanuman),
          ],
        ),
        const SizedBox(height: Sp.s12),
        Row(
          children: <Widget>[
            card(Deity.vishnu),
            const SizedBox(width: Sp.s12),
            card(Deity.shani),
          ],
        ),
        const SizedBox(height: Sp.s12),
        OptionRow(
          label: 'No day for now',
          selected: selected == Deity.none,
          onTap: () => onSelected(Deity.none),
        ),
      ],
    );
  }
}

/// "Your first note": when and what, from the real planner.
class _Preview extends ConsumerWidget {
  const _Preview({this.rituals = const <Ritual>{}, this.deity = Deity.none});

  final Set<Ritual> rituals;
  final Deity deity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final PreviewContext? ctx = ref.watch(previewContextProvider);
    final PlannedReminder? note = ctx == null
        ? null
        : firstNote(ctx, rituals: rituals, deity: deity);
    final String when = note == null
        ? 'Timed to your sun'
        : whenLabel(note.wall, ctx!.now);
    final String body =
        note?.body ??
        (ctx == null
            ? 'We work out the time from your city.'
            : 'Nothing in the next few weeks. We will tell you when it comes.');
    return Padding(
      padding: const EdgeInsets.only(top: Sp.s14),
      child: Semantics(
        container: true,
        label: 'Your first note. $when. $body',
        excludeSemantics: true,
        child: DCard(
          padding: const EdgeInsets.fromLTRB(Sp.s18, Sp.s14, Sp.s18, Sp.s14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: DIcon('diya', size: 22, glow: true),
              ),
              const SizedBox(width: Sp.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('YOUR FIRST NOTE', style: DType.ref(c.accent)),
                    const SizedBox(height: 2),
                    Text(when, style: DType.body(c.verse, size: 17)),
                    Text(body, style: DType.body(c.ink, size: 16)),
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
