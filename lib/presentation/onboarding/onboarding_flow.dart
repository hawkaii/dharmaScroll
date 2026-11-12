import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/feedback/sound_service.dart';
import '../../core/practice/practice.dart';
import '../../core/rituals/providers.dart';
import '../../core/rituals/reminder_backend.dart';
import '../../core/rituals/rituals.dart';
import '../../core/state/settings.dart';
import '../../design/info_sheet.dart';
import '../../design/lottie_art.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../auth/sign_in_panel.dart';
import '../practice/practice_builder.dart';
import '../practice/practice_screen.dart' show BackChevron;
import '../practice/tradition_explainer.dart';
import '../you/city_picker.dart';

/// Welcome, then five short steps: sign in, your city, your tradition, your
/// hour, your practice. Each step says in one line why it asks. Shown once.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  static const String welcomeLine1 = 'A conversation';
  static const String welcomeLine2 = 'on a battlefield.';
  static const String welcomeButton = 'Listen';
  static const String next = 'Continue';
  static const String signInTitle = 'Who is lighting\nthe lamp?';
  static const String cityTitle = 'Where do you\nwatch the sun?';
  static const String traditionTitle = 'How do you\nkeep Ekadashi?';
  static const String reminderTitle = 'When does your\nday begin?';
  static const String finishLabel = 'Light the first lamp';

  static const String whySignIn =
      'Signing in will keep your lamp and your verses if you change phones. '
      'For now, all of it stays on this phone.';
  static const String whyCity =
      'Your city tells us when the sun rises for you. Prayers follow the sun.';
  static const String whyTradition =
      'Families keep the Ekadashi fast in two ways. Some months, the days differ.';
  static const String whyHour =
      'Five verses will wait for you at this hour. Every day, the same quiet time.';
  static const String seeDifference = 'See the difference';

  /// Steps after welcome; the dashes count these.
  static const int steps = 5;

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  int _page = 0;
  bool _lit = false;

  SettingsNotifier get _n => ref.read(settingsProvider.notifier);

  void _go(int page) {
    // The button already tapped (sound + haptic); the page turn is the swipe.
    SoundService.instance.play(Sfx.swipe);
    setState(() => _page = page);
  }

  Future<void> _finish(PracticePlan plan) async {
    if (_lit) return;
    setState(() => _lit = true);
    // Lamp ignite: shimmer, with one soft pulse.
    SoundService.instance.play(Sfx.shimmer);
    Haptics.soft();
    // Save what the person saw, chosen or default, so it is fixed from now.
    final Settings s = ref.read(settingsProvider);
    _n
      ..setReminder(s.reminderMinutes)
      ..setCity(s.cityId)
      ..setTradition(s.tradition)
      ..setPractice(plan.rituals, plan.deity);
    await Future<void>.delayed(
      reduceMotion(context) ? Duration.zero : Motion.ignite,
    );
    if (!mounted) return;
    final ReminderBackend backend = ref.read(reminderBackendProvider);
    _n.completeOnboarding();
    // They just chose their reminders: this is the moment to ask.
    backend.requestPermission().ignore();
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final Settings s = ref.watch(settingsProvider);
    return Scaffold(
      backgroundColor: c.bg,
      body: Backdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Sp.screenSide,
              Sp.s6,
              Sp.screenSide,
              Sp.s12,
            ),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 44,
                  child: _page == 0
                      ? null
                      : Row(
                          children: <Widget>[
                            if (_page < OnboardingFlow.steps)
                              BackChevron(onTap: () => _go(_page - 1))
                            else
                              const SizedBox(width: 44),
                            Expanded(
                              child: Center(
                                child: ProgressDashes(
                                  total: OnboardingFlow.steps,
                                  filled: _page,
                                ),
                              ),
                            ),
                            const SizedBox(width: 44),
                          ],
                        ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Motion.snap,
                    switchInCurve: Motion.easeOut,
                    child: KeyedSubtree(
                      key: ValueKey<int>(_page),
                      child: switch (_page) {
                        0 => _Welcome(onNext: () => _go(1)),
                        1 => _Step(
                          art: Art.lotusSafe,
                          eyebrow: 'YOUR LIGHT',
                          title: OnboardingFlow.signInTitle,
                          why: OnboardingFlow.whySignIn,
                          footer: SignInPanel(onDone: () => _go(2)),
                          children: const <Widget>[],
                        ),
                        2 => _Step(
                          art: Art.citySun,
                          eyebrow: 'YOUR CITY',
                          title: OnboardingFlow.cityTitle,
                          why: OnboardingFlow.whyCity,
                          footer: PrimaryButton(
                            label: OnboardingFlow.next,
                            onPressed: () => _go(3),
                          ),
                          children: <Widget>[
                            CityPicker(
                              selected: s.cityId,
                              onSelected: _n.setCity,
                            ),
                          ],
                        ),
                        3 => _Step(
                          art: Art.twoPaths,
                          eyebrow: 'YOUR TRADITION',
                          title: OnboardingFlow.traditionTitle,
                          why: OnboardingFlow.whyTradition,
                          footer: PrimaryButton(
                            label: OnboardingFlow.next,
                            onPressed: () => _go(4),
                          ),
                          children: <Widget>[
                            for (final Tradition t
                                in Tradition.values) ...<Widget>[
                              OptionRow(
                                label: t.label,
                                hint: traditionHint(t),
                                selected: t == s.tradition,
                                onTap: () => _n.setTradition(t),
                              ),
                              const SizedBox(height: Sp.s12),
                            ],
                            _SeeDifference(
                              onTap: () => showTraditionExplainer(context),
                            ),
                          ],
                        ),
                        4 => _Step(
                          art: Art.hourDiya,
                          eyebrow: 'YOUR HOUR',
                          title: OnboardingFlow.reminderTitle,
                          why: OnboardingFlow.whyHour,
                          footer: PrimaryButton(
                            label: OnboardingFlow.next,
                            onPressed: () => _go(5),
                          ),
                          children: <Widget>[
                            _HourDial(
                              minutes: s.reminderMinutes,
                              onChanged: _n.setReminder,
                            ),
                          ],
                        ),
                        _ => PracticeBuilder(
                          initial: PracticeAnswers.from(s),
                          doneLabel: OnboardingFlow.finishLabel,
                          busy: _lit,
                          onBack: () => _go(4),
                          onDone: _finish,
                        ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One line under each tradition, for a child.
String traditionHint(Tradition t) => switch (t) {
  Tradition.smarta => 'Fast on the day Ekadashi meets the sunrise.',
  Tradition.vaishnava => 'Wait for an Ekadashi that is clean from dawn.',
  Tradition.unsure => 'We show both days when they differ.',
};

/// "See the difference" with the round "i".
class _SeeDifference extends StatelessWidget {
  const _SeeDifference({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InfoButton(topic: 'Smarta and Vaishnava', onTap: onTap),
        Flexible(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  OnboardingFlow.seeDifference,
                  style: DType.body(context.c.accent, size: 17),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A step: animation, eyebrow, title, the one line of why, the content.
class _Step extends StatelessWidget {
  const _Step({
    required this.art,
    required this.eyebrow,
    required this.title,
    required this.why,
    required this.children,
    required this.footer,
  });

  final Art art;
  final String eyebrow;
  final String title;
  final String why;
  final List<Widget> children;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return _Page(
      footer: footer,
      children: <Widget>[
        DLottie(art, height: 92),
        const SizedBox(height: Sp.s14),
        Text(eyebrow, style: DType.eyebrow(c.accent)),
        const SizedBox(height: Sp.s12),
        Semantics(
          header: true,
          child: Text(
            title,
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
        ...children,
      ],
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
                  const SizedBox(height: Sp.s12),
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

class _HourDial extends StatelessWidget {
  const _HourDial({required this.minutes, required this.onChanged});

  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final bool am = minutes < 12 * 60;
    return Column(
      children: <Widget>[
        Text(fmtTime(minutes), style: DType.hero(c.verse, size: 76)),
        Text(
          am ? 'AM  ·  DRAG TO CHANGE' : 'PM  ·  DRAG TO CHANGE',
          style: DType.eyebrow(c.faint),
        ),
        const SizedBox(height: Sp.s14),
        Semantics(
          label: 'Reminder time',
          value: '${fmtTime(minutes)} ${am ? 'AM' : 'PM'}',
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
