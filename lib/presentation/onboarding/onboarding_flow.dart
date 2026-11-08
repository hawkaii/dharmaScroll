import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/mascot.dart';
import 'onboarding_state.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

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
    final Duration d = AppMotion.resolve(context, AppMotion.normal);
    if (d == Duration.zero) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(index, duration: d, curve: AppMotion.enter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(onboardingProvider.notifier);
    return Scaffold(
      backgroundColor: context.colors.surfaceCanvas,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) {},
                children: <Widget>[
                  _WelcomeStep(onNext: () => _goTo(1)),
                  _IdentityStep(onNext: () => _goTo(2)),
                  _StreakStep(onNext: () => _goTo(3)),
                  _SpotlightStep(onDone: () => notifier.complete()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.s24),
              child: SmoothPageIndicator(
                controller: _controller,
                count: 4,
                effect: ExpandingDotsEffect(
                  activeDotColor: context.colors.accentKesar,
                  dotColor: context.colors.surfaceSunken,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onNext});
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpace.s24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Mascot(size: 96),
          const SizedBox(height: AppSpace.s16),
          Text('ॐ', style: AppType.sktL.copyWith(fontSize: 64, color: context.colors.accentKesar)),
          Text('DharmaScroll', style: AppType.d2.copyWith(color: context.colors.ink)),
          const SizedBox(height: AppSpace.s8),
          Text('Scroll less. Live more.', style: AppType.b3.copyWith(color: context.colors.inkMuted)),
          const SizedBox(height: AppSpace.s32),
          ElevatedButton(onPressed: onNext, child: const Text('Begin')),
        ],
      ),
    );
  }
}

class _IdentityStep extends ConsumerWidget {
  const _IdentityStep({required this.onNext});
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    const labels = <IdentityGoal, String>{
      IdentityGoal.casualSeeker: 'Casual seeker',
      IdentityGoal.regularSadhak: 'Regular sadhak',
      IdentityGoal.seriousYogi: 'Serious yogi',
      IdentityGoal.intenseTapasvi: 'Intense tapasvi',
    };
    return Padding(
      padding: const EdgeInsets.all(AppSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Who are you becoming?', style: AppType.d3.copyWith(color: context.colors.ink)),
          const SizedBox(height: AppSpace.s16),
          Wrap(
            spacing: AppSpace.s8,
            runSpacing: AppSpace.s8,
            children: labels.entries.map((e) => ChoiceChip(
              label: Text(e.value),
              selected: state.identityGoal == e.key,
              onSelected: (_) => notifier.setIdentityGoal(e.key),
            )).toList(),
          ),
          const Spacer(),
          ElevatedButton(onPressed: onNext, child: const Text('Next')),
        ],
      ),
    );
  }
}

class _StreakStep extends ConsumerWidget {
  const _StreakStep({required this.onNext});
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(AppSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Start your streak today?', style: AppType.d3.copyWith(color: context.colors.ink)),
          const SizedBox(height: AppSpace.s16),
          SwitchListTile(
            title: const Text('Begin streak today'),
            value: state.startStreakToday,
            onChanged: notifier.setStartStreakToday,
          ),
          const Spacer(),
          ElevatedButton(onPressed: onNext, child: const Text('Next')),
        ],
      ),
    );
  }
}

class _SpotlightStep extends StatelessWidget {
  const _SpotlightStep({required this.onDone});
  final VoidCallback onDone;
  @override
  Widget build(BuildContext context) {
    // TODO: wire showcaseview spotlight tour here.
    return Padding(
      padding: const EdgeInsets.all(AppSpace.s24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('You are ready', style: AppType.d2.copyWith(color: context.colors.ink)),
          const SizedBox(height: AppSpace.s16),
          ElevatedButton(onPressed: onDone, child: const Text('Start')),
        ],
      ),
    );
  }
}