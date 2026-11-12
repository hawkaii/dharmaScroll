import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/hard_button.dart';
import 'onboarding_state.dart';

/// First run: Welcome, Language, Reminder. Three screens, three taps.
///
/// No sign-up, no quiz, no permission prompt (the mic is asked for at the first
/// Mann Darpan). Finishing persists `onboardingComplete`, and the router never
/// shows this flow again. Styling is a placeholder on the existing tokens until
/// design board v3 lands; structure and copy follow board v2.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  static const String welcomeTitle = 'Your mind scrolls anyway.';
  static const String languageTitle = 'In which tongue shall the verse speak?';
  static const String reminderTitle = 'When shall we light the lamp?';
  static const String finishLabel = 'Light the first lamp';

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    HapticFeedback.lightImpact();
    final Duration d = AppMotion.resolve(context, AppMotion.page);
    if (d == Duration.zero) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(index, duration: d, curve: AppMotion.enter);
    }
  }

  void _finish() {
    HapticFeedback.lightImpact();
    ref.read(onboardingProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceCanvas,
      body: SafeArea(
        child: PageView(
          controller: _controller,
          // Forward only by the button, so every step is a deliberate tap.
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            _WelcomeStep(onNext: () => _goTo(1)),
            _LanguageStep(onNext: () => _goTo(2)),
            _ReminderStep(onDone: _finish),
          ],
        ),
      ),
    );
  }
}

/// Shared frame: scrollable body (so 200% text on 320 dp never overflows) and
/// one full-width button at the bottom.
class _StepFrame extends StatelessWidget {
  const _StepFrame({
    required this.children,
    required this.buttonLabel,
    required this.onPressed,
    this.center = false,
  });

  final List<Widget> children;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s24,
        AppSpace.s24,
        AppSpace.s24,
        AppSpace.s24,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: center
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      crossAxisAlignment: center
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpace.s16),
          HardButton(
            label: buttonLabel,
            block: true,
            variant: HardButtonVariant.gold,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    return _StepFrame(
      center: true,
      buttonLabel: 'Begin',
      onPressed: onNext,
      children: <Widget>[
        ExcludeSemantics(
          child: SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Lottie.asset(
                  'assets/lottie/breathing_orb.json',
                  width: 160,
                  height: 160,
                  animate: !reduceMotion,
                ),
                Text(
                  'ॐ',
                  style: AppType.sktL.copyWith(
                    fontSize: 64,
                    color: context.colors.accentKesar,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.s32),
        Semantics(
          header: true,
          child: Text(
            OnboardingFlow.welcomeTitle,
            textAlign: TextAlign.center,
            style: AppType.d2.copyWith(color: context.colors.ink),
          ),
        ),
        const SizedBox(height: AppSpace.s12),
        Text(
          'Let it scroll something\nthat lasts.',
          textAlign: TextAlign.center,
          style: AppType.b1.copyWith(color: context.colors.inkMuted),
        ),
      ],
    );
  }
}

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep({required this.onNext});

  final VoidCallback onNext;

  static const List<(LangPref, String, String)> _options =
      <(LangPref, String, String)>[
        (LangPref.hindiSanskrit, 'हिन्दी', 'Hindi'),
        (LangPref.englishSanskrit, 'English', 'Sanskrit + English'),
        (LangPref.hinglish, 'Hinglish', 'Roman + Hindi'),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LangPref selected = ref.watch(
      onboardingProvider.select((OnboardingState s) => s.language),
    );
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);

    return _StepFrame(
      buttonLabel: 'Continue',
      onPressed: onNext,
      children: <Widget>[
        Text(
          '1 OF 2',
          style: AppType.m1.copyWith(color: context.colors.accentKesar),
        ),
        const SizedBox(height: AppSpace.s12),
        Semantics(
          header: true,
          child: Text(
            OnboardingFlow.languageTitle,
            style: AppType.d3.copyWith(color: context.colors.ink),
          ),
        ),
        const SizedBox(height: AppSpace.s24),
        for (final (LangPref value, String title, String hint) in _options)
          _OptionRow(
            title: title,
            hint: hint,
            selected: selected == value,
            onTap: () => notifier.setLanguage(value),
          ),
      ],
    );
  }
}

class _ReminderStep extends ConsumerWidget {
  const _ReminderStep({required this.onDone});

  final VoidCallback onDone;

  static const int morning = 6 * 60 + 30;
  static const int evening = 20 * 60 + 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? at = ref.watch(
      onboardingProvider.select((OnboardingState s) => s.remindAtMinutes),
    );
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    return _StepFrame(
      buttonLabel: OnboardingFlow.finishLabel,
      onPressed: onDone,
      children: <Widget>[
        Text(
          '2 OF 2',
          style: AppType.m1.copyWith(color: context.colors.accentKesar),
        ),
        const SizedBox(height: AppSpace.s12),
        Semantics(
          header: true,
          child: Text(
            OnboardingFlow.reminderTitle,
            style: AppType.d3.copyWith(color: context.colors.ink),
          ),
        ),
        const SizedBox(height: AppSpace.s24),
        _OptionRow(
          title: 'Morning',
          hint: '6:30',
          selected: at == morning,
          onTap: () => notifier.setReminder(morning),
        ),
        _OptionRow(
          title: 'Evening',
          hint: '8:30',
          selected: at == evening,
          onTap: () => notifier.setReminder(evening),
        ),
        const SizedBox(height: AppSpace.s24),
        ExcludeSemantics(
          child: Lottie.asset(
            'assets/lottie/diya_flame.json',
            width: 96,
            height: 96,
            animate: !reduceMotion,
          ),
        ),
        const SizedBox(height: AppSpace.s8),
        Text(
          'One reminder a day. Never at night.',
          textAlign: TextAlign.center,
          style: AppType.b3.copyWith(color: context.colors.inkMuted),
        ),
      ],
    );
  }
}

/// A single-choice row. Selected = accent outline and a light fill.
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.title,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s12),
      child: Semantics(
        button: true,
        inMutuallyExclusiveGroup: true,
        selected: selected,
        label: '$title, $hint',
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: AppMotion.resolve(context, AppMotion.fast),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s20,
              vertical: AppSpace.s16,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? context.colors.surfaceSunken
                  : context.colors.surface,
              border: Border.all(
                color: selected
                    ? context.colors.accentKesar
                    : context.colors.border,
                width: selected ? 2 : AppBorder.hairline,
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: AppType.t2.copyWith(
                      fontFamilyFallback: AppType.latinFallback,
                      color: context.colors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.s8),
                Flexible(
                  child: Text(
                    hint,
                    textAlign: TextAlign.end,
                    style: AppType.c1.copyWith(color: context.colors.inkMuted),
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
