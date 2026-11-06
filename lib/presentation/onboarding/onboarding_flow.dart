import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/choice_chip_tag.dart';
import '../../core/widgets/hard_button.dart';
import '../../core/widgets/parchment.dart';
import 'onboarding_state.dart';

/// Splash → Language → FeedIntent → Nitya Path → the first shloka.
///
/// Four screens, three of them counted. The counter lives on the language step
/// even though it is the first one shown, because the source's "Step 1 of 3" is
/// a commitment device, not a progress indicator.
class OnboardingFlow extends ConsumerWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: context.colors.surfaceCanvas,
      body: AnimatedSwitcher(
        duration: AppMotion.resolve(context, AppMotion.normal),
        switchInCurve: AppMotion.enter,
        switchOutCurve: AppMotion.exit,
        child: KeyedSubtree(
          key: ValueKey<OnboardingStep>(state.step),
          child: switch (state.step) {
            OnboardingStep.splash => const _SplashStep(),
            OnboardingStep.language => const _LanguageStep(),
            OnboardingStep.intent => const _IntentStep(),
            OnboardingStep.goal => const _GoalStep(),
          },
        ),
      ),
    );
  }
}

// ── Splash ───────────────────────────────────────────────────────────────────

class _SplashStep extends ConsumerWidget {
  const _SplashStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ParchmentBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s24),
          child: Column(
            children: <Widget>[
              const Spacer(flex: 2),
              Text(
                'ॐ',
                style: AppType.sktL.copyWith(
                  fontSize: 64,
                  color: context.colors.accentKesar,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpace.s16),
              Text(
                'DharmaScroll',
                style: AppType.d2.copyWith(color: context.colors.ink),
              ),
              const SizedBox(height: AppSpace.s8),
              Text(
                'Scroll less. Live more.',
                style: AppType.b3.copyWith(color: context.colors.inkMuted),
              ),
              const Spacer(flex: 3),
              Text(
                'योगः कर्मसु कौशलम्',
                textAlign: TextAlign.center,
                style: AppType.sktM.copyWith(color: context.colors.field),
              ),
              const SizedBox(height: AppSpace.s6),
              Text(
                'YOGA IS SKILL IN ACTION · 2.50',
                style: AppType.m1.copyWith(color: context.colors.inkMuted),
              ),
              const Spacer(flex: 2),
              HardButton(
                label: 'Shuru karein · Begin',
                block: true,
                onPressed: () => ref.read(onboardingProvider.notifier).next(),
              ),
              const SizedBox(height: AppSpace.s8),
              Text(
                'No sign-up needed',
                style: AppType.c1.copyWith(color: context.colors.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Language ─────────────────────────────────────────────────────────────────

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingProvider);
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);

    return _StepScaffold(
      step: 1,
      title: 'Kis bhasha mein padhein?',
      subtitle: 'Choose your reading language',
      body: <Widget>[
        _ChoiceRow(
          label: 'हिन्दी + संस्कृत',
          selected: state.language == LangPref.hindiSanskrit,
          onTap: () => notifier.setLanguage(LangPref.hindiSanskrit),
        ),
        _ChoiceRow(
          label: 'English + Sanskrit',
          selected: state.language == LangPref.englishSanskrit,
          onTap: () => notifier.setLanguage(LangPref.englishSanskrit),
        ),
        _ChoiceRow(
          label: 'Hinglish (both)',
          selected: state.language == LangPref.hinglish,
          onTap: () => notifier.setLanguage(LangPref.hinglish),
        ),
        _ChoiceRow(
          label: 'मराठी · বাংলা · தமிழ் …',
          selected: false,
          trailing: 'Soon',
          onTap: () {},
        ),
        const SizedBox(height: AppSpace.s16),
        Container(height: 1, color: context.colors.borderQuiet),
        const SizedBox(height: AppSpace.s8),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Show transliteration',
                style: AppType.b2.copyWith(color: context.colors.ink),
              ),
            ),
            Switch(
              value: state.showTransliteration,
              activeThumbColor: context.colors.onPrimary,
              activeTrackColor: context.colors.primary,
              onChanged: notifier.setTransliteration,
            ),
          ],
        ),
        Text(
          'Baad mein Settings se badal sakte hain.',
          style: AppType.c1.copyWith(color: context.colors.inkMuted),
        ),
      ],
      action: HardButton(
        label: 'Aage · Next',
        block: true,
        onPressed: notifier.next,
      ),
    );
  }
}

// ── FeedIntent ───────────────────────────────────────────────────────────────────

class _IntentStep extends ConsumerWidget {
  const _IntentStep();

  static const Map<FeedIntent, String> _labels = <FeedIntent, String>{
    FeedIntent.lessPhone: 'Less phone time',
    FeedIntent.stress: 'Stress & anxiety',
    FeedIntent.finishGita: 'Finish the Gita',
    FeedIntent.anger: 'Anger',
    FeedIntent.focus: 'Focus for exams',
    FeedIntent.career: 'Career confusion',
    FeedIntent.relationships: 'Relationships',
    FeedIntent.grief: 'Grief',
    FeedIntent.devotion: 'Daily devotion',
    FeedIntent.teachKids: 'Teach my kids',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingProvider);
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);

    return _StepScaffold(
      step: 2,
      title: 'What brings you here?',
      subtitle: 'Pick any. We\'ll tune your feed.',
      body: <Widget>[
        Wrap(
          spacing: AppSpace.s8,
          runSpacing: AppSpace.s4,
          children: <Widget>[
            for (final MapEntry<FeedIntent, String> entry in _labels.entries)
              ChoiceChipTag(
                label: entry.value,
                selected: state.intents.contains(entry.key),
                onTap: () {
                  if (!notifier.toggleIntent(entry.key)) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            '5 hi chunein, warna feed dhundhla ho jayega.',
                            style: AppType.b3,
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: context.colors.ink,
                        ),
                      );
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpace.s24),
        Text(
          'How familiar are you with the Gita?',
          style: AppType.h1.copyWith(color: context.colors.ink),
        ),
        const SizedBox(height: AppSpace.s8),
        Wrap(
          spacing: AppSpace.s8,
          children: <Widget>[
            ChoiceChipTag(
              label: 'New',
              selected: state.familiarity == Familiarity.newToGita,
              onTap: () => notifier.setFamiliarity(Familiarity.newToGita),
            ),
            ChoiceChipTag(
              label: 'Know a few shlokas',
              selected: state.familiarity == Familiarity.fewShlokas,
              onTap: () => notifier.setFamiliarity(Familiarity.fewShlokas),
            ),
            ChoiceChipTag(
              label: 'Studied it',
              selected: state.familiarity == Familiarity.studied,
              onTap: () => notifier.setFamiliarity(Familiarity.studied),
            ),
          ],
        ),
      ],
      action: Row(
        children: <Widget>[
          Expanded(
            child: HardButton(
              label: 'Skip',
              variant: HardButtonVariant.ghost,
              block: true,
              onPressed: notifier.next,
            ),
          ),
          const SizedBox(width: AppSpace.s12),
          Expanded(
            flex: 2,
            child: HardButton(
              label: 'Aage · Next',
              block: true,
              onPressed: notifier.next,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nitya Path ───────────────────────────────────────────────────────────────

class _GoalStep extends ConsumerWidget {
  const _GoalStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingProvider);
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);

    return _StepScaffold(
      step: 3,
      title: 'Your Nitya Path',
      subtitle: 'A small daily promise you can keep',
      body: <Widget>[
        _ChoiceRow(
          label: '5 min · Casual',
          trailing: '1 shloka',
          selected: state.goalMinutes == 5,
          onTap: () => notifier.setGoal(5),
        ),
        _ChoiceRow(
          label: '10 min · Regular',
          trailing: '5 shlokas',
          selected: state.goalMinutes == 10,
          onTap: () => notifier.setGoal(10),
        ),
        _ChoiceRow(
          label: '20 min · Serious',
          trailing: '5 shlokas + lesson',
          selected: state.goalMinutes == 20,
          onTap: () => notifier.setGoal(20),
        ),
        const SizedBox(height: AppSpace.s20),
        Text(
          'Remind me at',
          style: AppType.h1.copyWith(color: context.colors.ink),
        ),
        const SizedBox(height: AppSpace.s8),
        Wrap(
          spacing: AppSpace.s8,
          children: <Widget>[
            ChoiceChipTag(
              label: '6:30 am',
              selected: state.remindAtMinutes == 6 * 60 + 30,
              onTap: () => notifier.setReminder(6 * 60 + 30),
            ),
            ChoiceChipTag(
              label: '9:00 pm',
              selected: state.remindAtMinutes == 21 * 60,
              onTap: () => notifier.setReminder(21 * 60),
            ),
            ChoiceChipTag(
              label: '+ Custom',
              selected: state.remindAtMinutes == null,
              onTap: () => notifier.setReminder(null),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.s16),
        Text(
          'Includes 2 free Vishram (rest) days every month.',
          style: AppType.c1.copyWith(color: context.colors.inkMuted),
        ),
        const SizedBox(height: AppSpace.s4),
        Text(
          'We\'ll ask before we ever send a reminder.',
          style: AppType.c1.copyWith(color: context.colors.inkMuted),
        ),
      ],
      action: Column(
        children: <Widget>[
          HardButton(
            label: 'Start my first shloka',
            block: true,
            onPressed: notifier.complete,
          ),
          const SizedBox(height: AppSpace.s8),
          GestureDetector(
            onTap: notifier.finishEarly,
            child: Text(
              'Set later',
              style: AppType.l1.copyWith(color: context.colors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared chrome ────────────────────────────────────────────────────────────

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.action,
  });

  final int step;
  final String title;
  final String subtitle;
  final List<Widget> body;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.s20,
          AppSpace.s16,
          AppSpace.s20,
          AppSpace.s16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Step $step of 3',
              style: AppType.m1.copyWith(color: context.colors.inkMuted),
            ),
            const SizedBox(height: AppSpace.s8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Row(
                children: <Widget>[
                  for (int i = 1; i <= 3; i++)
                    Expanded(
                      child: Container(
                        height: 5,
                        margin: const EdgeInsets.only(right: 4),
                        color: i <= step
                            ? context.colors.accentKesar
                            : context.colors.surfaceSunken,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.s24),
            Text(title, style: AppType.d3.copyWith(color: context.colors.ink)),
            const SizedBox(height: AppSpace.s6),
            Text(
              subtitle,
              style: AppType.b3.copyWith(color: context.colors.inkMuted),
            ),
            const SizedBox(height: AppSpace.s24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: body,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.s12),
            action,
          ],
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s16,
            vertical: AppSpace.s12,
          ),
          decoration: BoxDecoration(
            color: selected ? context.colors.surface : context.colors.surface,
            border: Border.all(
              color: selected
                  ? context.colors.accentKesar
                  : context.colors.border,
              width: selected ? AppBorder.b : AppBorder.thin,
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: AppType.h1.copyWith(color: context.colors.ink),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: AppType.m1.copyWith(
                    fontSize: 9,
                    color: context.colors.inkMuted,
                  ),
                ),
              const SizedBox(width: AppSpace.s8),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 18,
                color: selected
                    ? context.colors.accentKesar
                    : context.colors.inkFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
