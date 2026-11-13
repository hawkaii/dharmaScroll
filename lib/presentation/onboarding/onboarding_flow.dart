import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/auth/auth_service.dart';
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
import '../../l10n/l10n.dart';
import '../auth/sign_in_panel.dart';
import '../language/language_picker.dart';
import '../practice/practice_builder.dart';
import '../practice/practice_screen.dart' show BackChevron;
import '../practice/tradition_explainer.dart';
import '../you/city_picker.dart';

/// Language and text size first, so everything after is readable. Then a
/// welcome and five short steps: sign in, your city, your tradition, your
/// hour, your practice. Each step says in one line why it asks, has a clear
/// Back, and (after the first page and the welcome) a Skip. Shown once.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  /// The pages, in order.
  static const int pageLanguage = 0;
  static const int pageTextSize = 1;
  static const int pageWelcome = 2;
  static const int pageSignIn = 3;
  static const int pageCity = 4;
  static const int pageTradition = 5;
  static const int pageHour = 6;
  static const int pagePractice = 7;

  /// Steps after the welcome; the dashes count these.
  static const int steps = 5;

  /// Both languages at once: the person has not chosen yet.
  static const String languageTitle = 'Choose your language\nअपनी भाषा चुनिए';
  static const String languageEyebrow = 'LANGUAGE  ·  भाषा';
  static const String languageWhy =
      'You can change this later.\nइसे बाद में भी बदल सकते हैं।';

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

  void _skip() {
    switch (_page) {
      case OnboardingFlow.pageSignIn:
        // Skipping sign-in is being a guest: nothing else to ask.
        ref.read(authProvider.notifier).guest().then((_) {
          if (mounted) _go(OnboardingFlow.pageCity);
        });
      case OnboardingFlow.pagePractice:
        _finish(
          ref
              .read(practiceSuggesterProvider)
              .suggest(PracticeAnswers.from(ref.read(settingsProvider))),
        );
      default:
        _go(_page + 1);
    }
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
      ..setLanguage(s.language)
      ..setTextSize(s.textSize)
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
    final AppLocalizations l = context.l;
    final Settings s = ref.watch(settingsProvider);
    final bool canSkip =
        _page != OnboardingFlow.pageLanguage &&
        _page != OnboardingFlow.pageWelcome;
    final bool dashes = _page >= OnboardingFlow.pageSignIn;
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
                // Back on the left, Skip on the right, on every step they
                // apply to. The first page has nothing behind it.
                SizedBox(
                  height: 52,
                  child: _page == OnboardingFlow.pageLanguage
                      ? null
                      : Row(
                          children: <Widget>[
                            // The practice questions carry their own Back.
                            if (_page < OnboardingFlow.pagePractice)
                              BackChevron(onTap: () => _go(_page - 1))
                            else
                              const SizedBox(width: 48),
                            const Spacer(),
                            if (canSkip)
                              TextAction(label: l.skip, onPressed: _skip),
                          ],
                        ),
                ),
                if (dashes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sp.s6),
                    child: ProgressDashes(
                      total: OnboardingFlow.steps,
                      filled: _page - OnboardingFlow.pageWelcome,
                    ),
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Motion.snap,
                    switchInCurve: Motion.easeOut,
                    child: KeyedSubtree(
                      key: ValueKey<int>(_page),
                      child: switch (_page) {
                        OnboardingFlow.pageLanguage => _Step(
                          header: DIcon(
                            'conch',
                            size: 56,
                            color: c.accent,
                            glow: true,
                          ),
                          eyebrow: OnboardingFlow.languageEyebrow,
                          title: OnboardingFlow.languageTitle,
                          why: OnboardingFlow.languageWhy,
                          footer: PrimaryButton(
                            label: l.continueLabel,
                            onPressed: () => _go(OnboardingFlow.pageTextSize),
                          ),
                          children: const <Widget>[LanguageTiles()],
                        ),
                        OnboardingFlow.pageTextSize => _Step(
                          header: DIcon(
                            'feather',
                            size: 56,
                            color: c.accent,
                            glow: true,
                          ),
                          eyebrow: l.textSizeEyebrow,
                          title: l.textSizeTitle,
                          why: l.textSizeWhy,
                          footer: PrimaryButton(
                            label: l.continueLabel,
                            onPressed: () => _go(OnboardingFlow.pageWelcome),
                          ),
                          children: const <Widget>[TextSizeChoice()],
                        ),
                        OnboardingFlow.pageWelcome => _Welcome(
                          onNext: () => _go(OnboardingFlow.pageSignIn),
                        ),
                        OnboardingFlow.pageSignIn => _Step(
                          art: Art.lotusSafe,
                          eyebrow: l.eyebrowLight,
                          title: l.signInTitle,
                          why: l.whySignIn,
                          footer: SignInPanel(
                            onDone: () => _go(OnboardingFlow.pageCity),
                          ),
                          children: const <Widget>[],
                        ),
                        OnboardingFlow.pageCity => _Step(
                          art: Art.citySun,
                          eyebrow: l.eyebrowCity,
                          title: l.cityTitle,
                          why: l.whyCity,
                          footer: PrimaryButton(
                            label: l.continueLabel,
                            onPressed: () => _go(OnboardingFlow.pageTradition),
                          ),
                          children: <Widget>[
                            CityPicker(
                              selected: s.cityId,
                              onSelected: _n.setCity,
                            ),
                          ],
                        ),
                        OnboardingFlow.pageTradition => _Step(
                          art: Art.twoPaths,
                          eyebrow: l.eyebrowTradition,
                          title: l.traditionTitle,
                          why: l.whyTradition,
                          footer: PrimaryButton(
                            label: l.continueLabel,
                            onPressed: () => _go(OnboardingFlow.pageHour),
                          ),
                          children: <Widget>[
                            for (final Tradition t
                                in Tradition.values) ...<Widget>[
                              OptionRow(
                                label: traditionLabel(l, t),
                                hint: traditionHint(l, t),
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
                        OnboardingFlow.pageHour => _Step(
                          art: Art.hourDiya,
                          eyebrow: l.eyebrowHour,
                          title: l.reminderTitle,
                          why: l.whyHour,
                          footer: PrimaryButton(
                            label: l.continueLabel,
                            onPressed: () => _go(OnboardingFlow.pagePractice),
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
                          doneLabel: l.finishLabel,
                          busy: _lit,
                          onBack: () => _go(OnboardingFlow.pageHour),
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

String traditionLabel(AppLocalizations l, Tradition t) => switch (t) {
  Tradition.smarta => l.traditionSmarta,
  Tradition.vaishnava => l.traditionVaishnava,
  Tradition.unsure => l.traditionUnsure,
};

/// One line under each tradition, for a child.
String traditionHint(AppLocalizations l, Tradition t) => switch (t) {
  Tradition.smarta => l.hintSmarta,
  Tradition.vaishnava => l.hintVaishnava,
  Tradition.unsure => l.hintUnsure,
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
        InfoButton(topic: context.l.topicSmartaVaishnava, onTap: onTap),
        Flexible(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  context.l.seeDifference,
                  style: DType.body(context.c.accent, size: 18),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A step: picture, eyebrow, title, the one line of why, the content.
class _Step extends StatelessWidget {
  const _Step({
    this.art,
    this.header,
    required this.eyebrow,
    required this.title,
    required this.why,
    required this.children,
    required this.footer,
  });

  /// An animation, or [header] for a still symbol.
  final Art? art;
  final Widget? header;
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
        if (art != null) DLottie(art!, height: 92) else ?header,
        const SizedBox(height: Sp.s14),
        Text(
          eyebrow,
          style: DType.eyebrow(c.accent),
          textAlign: TextAlign.center,
        ),
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
          style: DType.body(c.mute, size: 18),
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
    // The content scrolls; the button stays in reach at the bottom, so a
    // long page at a big text size never hides "Continue".
    return Column(
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Sp.s14),
        footer,
        const SizedBox(height: Sp.s12),
      ],
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
    final AppLocalizations l = context.l;
    return _Page(
      footer: PrimaryButton(label: l.welcomeButton, onPressed: widget.onNext),
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
            '${l.welcomeLine1}\n${l.welcomeLine2}',
            textAlign: TextAlign.center,
            style: DType.title(c.ink, compact: true),
          ),
        ),
        const SizedBox(height: Sp.s14),
        Text(
          l.welcomeSub,
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

  static const int _min = 4 * 60;
  static const int _max = 22 * 60;

  void _nudge(int by) {
    final int next = (minutes + by).clamp(_min, _max);
    if (next != minutes) {
      Haptics.tick();
      onChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final AppLocalizations l = context.l;
    final bool am = minutes < 12 * 60;
    return Column(
      children: <Widget>[
        Text(fmtTime(minutes), style: DType.hero(c.verse, size: 76)),
        Text(
          am ? l.dragToChangeAm : l.dragToChangePm,
          textAlign: TextAlign.center,
          style: DType.eyebrow(c.mute),
        ),
        const SizedBox(height: Sp.s14),
        Semantics(
          label: l.reminderTimeLabel,
          value: '${fmtTime(minutes)} ${am ? 'AM' : 'PM'}',
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Tok.marigold,
              inactiveTrackColor: c.line,
              thumbColor: Tok.marigold,
              overlayColor: Tok.marigold.withValues(alpha: 0.15),
            ),
            child: Slider(
              min: _min.toDouble(),
              max: _max.toDouble(),
              divisions: (18 * 60) ~/ 15,
              value: minutes.toDouble().clamp(_min, _max).toDouble(),
              onChanged: (double v) {
                if (v.round() != minutes) Haptics.tick();
                onChanged(v.round());
              },
            ),
          ),
        ),
        // Dragging is hard for a shaky hand: two plain buttons do the same.
        const SizedBox(height: Sp.s6),
        Row(
          children: <Widget>[
            Expanded(
              child: SecondaryButton(
                label: l.earlier15,
                onPressed: () => _nudge(-15),
              ),
            ),
            const SizedBox(width: Sp.s12),
            Expanded(
              child: SecondaryButton(
                label: l.later15,
                onPressed: () => _nudge(15),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
