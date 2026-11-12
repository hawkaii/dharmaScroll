import 'package:flutter/material.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/hard_button.dart';

/// The evening check-in.
///
/// Three answers, all the same size and the same weight. "Aaj nahi hua" is not
/// a link, not a smaller button, and not a red one — honesty has to be as easy
/// as success or the game punishes the truth.
Future<void> showSankalpCheckIn(
  BuildContext context, {
  required String promise,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.colors.scrim,
    builder: (BuildContext ctx) => SankalpCheckIn(promise: promise),
  );
}

enum _Outcome { done, partly, notToday }

class SankalpCheckIn extends StatefulWidget {
  const SankalpCheckIn({super.key, required this.promise});

  final String promise;

  @override
  State<SankalpCheckIn> createState() => _SankalpCheckInState();
}

class _SankalpCheckInState extends State<SankalpCheckIn> {
  _Outcome? _outcome;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border, width: AppBorder.hairline),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sm),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s24,
        AppSpace.s12,
        AppSpace.s24,
        AppSpace.s24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.ink.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpace.s24),
            Text(
              'Aaj ka Sankalp',
              style: AppType.t2.copyWith(color: context.colors.ink),
            ),
            const SizedBox(height: AppSpace.s16),
            Container(
              padding: const EdgeInsets.only(left: AppSpace.s12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: context.colors.gold,
                    width: AppBorder.hairline,
                  ),
                ),
              ),
              child: Text(
                '“${widget.promise}”',
                style: AppType.b1.copyWith(color: context.colors.ink),
              ),
            ),
            const SizedBox(height: AppSpace.s24),
            if (_outcome == null) ...<Widget>[
              HardButton(
                label: 'Hua',
                icon: Icons.check,
                block: true,
                onPressed: () => setState(() => _outcome = _Outcome.done),
              ),
              const SizedBox(height: AppSpace.s8),
              HardButton(
                label: 'Aadha hua',
                variant: HardButtonVariant.secondary,
                block: true,
                onPressed: () => setState(() => _outcome = _Outcome.partly),
              ),
              const SizedBox(height: AppSpace.s8),
              HardButton(
                label: 'Aaj nahi hua',
                variant: HardButtonVariant.secondary,
                block: true,
                onPressed: () => setState(() => _outcome = _Outcome.notToday),
              ),
              const SizedBox(height: AppSpace.s16),
              Text(
                'Sach bolne ke points hain. Jhooth ke nahi.',
                textAlign: TextAlign.center,
                style: AppType.c1.copyWith(color: context.colors.inkMuted),
              ),
            ] else
              _OutcomeCard(
                outcome: _outcome!,
                onDone: () => Navigator.of(context).maybePop(),
              ),
          ],
        ),
      ),
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard({required this.outcome, required this.onDone});

  final _Outcome outcome;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final (
      String headline,
      String body,
      String delta,
      bool good,
    ) = switch (outcome) {
      _Outcome.done => (
        'Sankalp nibhaya.',
        'Shaam ko yaad rakhne wali baat yahi hai.',
        '+25',
        true,
      ),
      _Outcome.partly => (
        'Aadha hua.',
        'Aadha bhi kaam hai. Kal poora karna zaroori nahi.',
        '+10',
        true,
      ),
      _Outcome.notToday => (
        'Theek hai. Kal ek chhota sa try.',
        'Aaj nahi hua — ismein koi kami nahi hai. Koi points nahi kate.',
        '0',
        false,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSpace.s16),
          decoration: BoxDecoration(
            color: good
                ? context.colors.successTint
                : context.colors.surfaceSunken,
            border: Border.all(
              color: good ? context.colors.success : context.colors.borderQuiet,
              width: good ? AppBorder.hairline : 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                headline,
                style: AppType.h1.copyWith(color: context.colors.ink),
              ),
              const SizedBox(height: AppSpace.s4),
              Text(
                body,
                style: AppType.b3.copyWith(color: context.colors.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.s12),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Moksh Points',
                style: AppType.m1.copyWith(color: context.colors.inkMuted),
              ),
            ),
            Text(
              delta == '0' ? '0' : delta,
              style: AppType.m2.copyWith(
                color: good ? context.colors.success : context.colors.inkFaint,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.s16),
        HardButton(label: 'Theek hai', block: true, onPressed: onDone),
      ],
    );
  }
}
