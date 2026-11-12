import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/feedback/sound_service.dart';
import '../../core/rituals/providers.dart';
import '../../core/rituals/reminder_backend.dart';
import '../../core/rituals/rituals.dart';
import '../../core/state/settings.dart';
import '../../design/effects.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../you/city_picker.dart';

/// Five light screens: welcome, the ritual, your city, your Ekadashi rule, the
/// hour. Shown once.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  static const String welcomeLine1 = 'A conversation';
  static const String welcomeLine2 = 'on a battlefield.';
  static const String welcomeButton = 'Listen';
  static const String ritualButton = 'Continue';
  static const String cityTitle = 'Where do you\nwatch the sun?';
  static const String traditionTitle = 'How do you\nkeep Ekadashi?';
  static const String reminderTitle = 'When does your\nday begin?';
  static const String finishLabel = 'Light the first lamp';

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  int _page = 0;
  int _minutes = 6 * 60 + 30;
  bool _lit = false;
  String _cityId = Settings.defaultCityId;
  Tradition _tradition = Tradition.unsure;

  void _next() {
    // The button already tapped (sound + haptic); the page turn is the swipe.
    SoundService.instance.play(Sfx.swipe);
    setState(() => _page++);
  }

  Future<void> _finish() async {
    if (_lit) return;
    setState(() => _lit = true);
    // Lamp ignite: shimmer, with one soft pulse.
    SoundService.instance.play(Sfx.shimmer);
    Haptics.soft();
    final SettingsNotifier n = ref.read(settingsProvider.notifier);
    n.setReminder(_minutes);
    n.setCity(_cityId);
    n.setTradition(_tradition);
    await Future<void>.delayed(
      reduceMotion(context) ? Duration.zero : Motion.ignite,
    );
    if (!mounted) return;
    final ReminderBackend backend = ref.read(reminderBackendProvider);
    n.completeOnboarding();
    // They just chose an hour: this is the moment to ask to remind them.
    backend.requestPermission().ignore();
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      body: Backdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Sp.screenSide,
              Sp.s18,
              Sp.screenSide,
              Sp.screenBottom,
            ),
            child: AnimatedSwitcher(
              duration: Motion.snap,
              switchInCurve: Motion.easeOut,
              child: KeyedSubtree(
                key: ValueKey<int>(_page),
                child: switch (_page) {
                  0 => _Welcome(onNext: _next),
                  1 => _Ritual(onNext: _next),
                  2 => _CityStep(
                    selected: _cityId,
                    onSelected: (String id) => setState(() => _cityId = id),
                    onNext: _next,
                  ),
                  3 => _TraditionStep(
                    selected: _tradition,
                    onSelected: (Tradition t) => setState(() => _tradition = t),
                    onNext: _next,
                  ),
                  _ => _Reminder(
                    minutes: _minutes,
                    lit: _lit,
                    onChanged: (int m) => setState(() => _minutes = m),
                    onFinish: _finish,
                  ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.children, required this.footer});

  final List<Widget> children;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: children,
                    ),
                  ),
                  const SizedBox(height: Sp.s18),
                  footer,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Welcome extends StatefulWidget {
  const _Welcome({required this.onNext});

  final VoidCallback onNext;

  @override
  State<_Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<_Welcome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _aura = AnimationController(
    vsync: this,
    duration: Motion.pulse,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started && !reduceMotion(context)) {
      _aura.repeat(reverse: true);
      _started = true;
    }
  }

  @override
  void dispose() {
    _aura.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return _Page(
      footer: PrimaryButton(
        label: OnboardingFlow.welcomeButton,
        onPressed: widget.onNext,
      ),
      children: <Widget>[
        ExcludeSemantics(
          child: AnimatedBuilder(
            animation: _aura,
            builder: (BuildContext context, Widget? child) => Transform.scale(
              scale: 1 + 0.07 * Curves.easeInOut.transform(_aura.value),
              child: child,
            ),
            child: SvgPicture.asset(
              'assets/svg/emblem.svg',
              width: 240,
              height: 240,
            ),
          ),
        ),
        const SizedBox(height: Sp.s22),
        Semantics(
          header: true,
          child: Text(
            '${OnboardingFlow.welcomeLine1}\n${OnboardingFlow.welcomeLine2}',
            textAlign: TextAlign.center,
            style: DType.title(c.ink, compact: true),
          ),
        ),
        const SizedBox(height: Sp.s14),
        Text(
          'Five thousand years old.\nListen in.',
          textAlign: TextAlign.center,
          style: DType.body(c.mute),
        ),
      ],
    );
  }
}

class _Ritual extends StatelessWidget {
  const _Ritual({required this.onNext});

  final VoidCallback onNext;

  static const List<(String, String, String)> rows = <(String, String, String)>[
    ('conch', 'Hear', 'Five verses. Then it ends.'),
    ('path-stone', 'Walk', 'One step on the path.'),
    ('flute', 'Speak', 'Tell it your mind. A verse answers.'),
  ];

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final bool still = reduceMotion(context);
    return _Page(
      footer: PrimaryButton(
        label: OnboardingFlow.ritualButton,
        onPressed: onNext,
      ),
      children: <Widget>[
        Text('SIX QUIET MINUTES', style: DType.eyebrow(c.accent)),
        const SizedBox(height: Sp.s14),
        Semantics(
          header: true,
          child: Text(
            'One ritual,\neach day.',
            textAlign: TextAlign.center,
            style: DType.title(c.ink),
          ),
        ),
        const SizedBox(height: Sp.s34),
        for (int i = 0; i < rows.length; i++)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: still ? 1 : 0, end: 1),
            duration: Duration(milliseconds: 400 + i * 400),
            curve: Motion.easeOut,
            builder: (BuildContext context, double t, Widget? child) =>
                Opacity(opacity: t, child: child),
            child: Padding(
              padding: const EdgeInsets.only(bottom: Sp.s22),
              child: Row(
                children: <Widget>[
                  DIcon(rows[i].$1, size: 36, glow: true),
                  const SizedBox(width: Sp.s18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(rows[i].$2, style: DType.body(c.ink, size: 24)),
                        Text(rows[i].$3, style: DType.body(c.mute, size: 17)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CityStep extends StatelessWidget {
  const _CityStep({
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final String selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return _Page(
      footer: PrimaryButton(
        label: OnboardingFlow.ritualButton,
        onPressed: onNext,
      ),
      children: <Widget>[
        Text('YOUR CITY', style: DType.eyebrow(c.accent)),
        const SizedBox(height: Sp.s14),
        Semantics(
          header: true,
          child: Text(
            OnboardingFlow.cityTitle,
            textAlign: TextAlign.center,
            style: DType.title(c.ink, compact: true),
          ),
        ),
        const SizedBox(height: Sp.s14),
        Text(
          'Sunrise and sunset set your reminders.',
          textAlign: TextAlign.center,
          style: DType.body(c.mute, size: 17),
        ),
        const SizedBox(height: Sp.s22),
        CityPicker(selected: selected, onSelected: onSelected),
      ],
    );
  }
}

class _TraditionStep extends StatelessWidget {
  const _TraditionStep({
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final Tradition selected;
  final ValueChanged<Tradition> onSelected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return _Page(
      footer: PrimaryButton(
        label: OnboardingFlow.ritualButton,
        onPressed: onNext,
      ),
      children: <Widget>[
        Text('YOUR TRADITION', style: DType.eyebrow(c.accent)),
        const SizedBox(height: Sp.s14),
        Semantics(
          header: true,
          child: Text(
            OnboardingFlow.traditionTitle,
            textAlign: TextAlign.center,
            style: DType.title(c.ink, compact: true),
          ),
        ),
        const SizedBox(height: Sp.s22),
        for (final Tradition t in Tradition.values) ...<Widget>[
          OptionRow(
            label: t.label,
            selected: t == selected,
            onTap: () => onSelected(t),
          ),
          const SizedBox(height: Sp.s12),
        ],
        Text(
          selected == Tradition.unsure
              ? 'When the two differ, we show both dates.'
              : 'You can change this later in You.',
          textAlign: TextAlign.center,
          style: DType.body(c.mute, size: 16),
        ),
      ],
    );
  }
}

class _Reminder extends StatelessWidget {
  const _Reminder({
    required this.minutes,
    required this.lit,
    required this.onChanged,
    required this.onFinish,
  });

  final int minutes;
  final bool lit;
  final ValueChanged<int> onChanged;
  final VoidCallback onFinish;

  static String hhmm(int m) {
    final int h = (m ~/ 60) % 12 == 0 ? 12 : (m ~/ 60) % 12;
    return '$h:${(m % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return _Page(
      footer: PrimaryButton(
        label: OnboardingFlow.finishLabel,
        onPressed: lit ? null : onFinish,
      ),
      children: <Widget>[
        AnimatedSwitcher(
          duration: Motion.ignite,
          child: Diya(key: ValueKey<bool>(lit), size: 110, lit: lit),
        ),
        const SizedBox(height: Sp.s22),
        Text('THE ONLY QUESTION', style: DType.eyebrow(c.accent)),
        const SizedBox(height: Sp.s14),
        Semantics(
          header: true,
          child: Text(
            OnboardingFlow.reminderTitle,
            textAlign: TextAlign.center,
            style: DType.title(c.ink, compact: true),
          ),
        ),
        const SizedBox(height: Sp.s22),
        Text(hhmm(minutes), style: DType.hero(c.verse, size: 76)),
        Text(
          minutes < 12 * 60 ? 'AM  ·  DRAG TO CHANGE' : 'PM  ·  DRAG TO CHANGE',
          style: DType.eyebrow(c.faint),
        ),
        const SizedBox(height: Sp.s14),
        Semantics(
          label: 'Reminder time',
          value: '${hhmm(minutes)} ${minutes < 12 * 60 ? 'AM' : 'PM'}',
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Tok.marigold,
              inactiveTrackColor: c.line,
              thumbColor: Tok.marigold,
              overlayColor: Tok.marigold.withValues(alpha: 0.15),
            ),
            child: Slider(
              min: 4 * 60,
              max: 22 * 60,
              divisions: (18 * 60) ~/ 15,
              value: minutes.toDouble().clamp(4 * 60, 22 * 60),
              onChanged: (double v) {
                if (v.round() != minutes) Haptics.tick();
                onChanged(v.round());
              },
            ),
          ),
        ),
      ],
    );
  }
}
