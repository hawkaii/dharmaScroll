import 'package:flutter/material.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/paper_plate.dart';

/// The ledger, made auditable so the economy never feels arbitrary.
///
/// Every negative row carries a written reason. There is no row that says
/// "you were sad", because that row does not exist.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const List<
    ({String label, String reason, String delta, bool negative})
  >
  _today = <({String label, String reason, String delta, bool negative})>[
    (label: 'Sankalp kept', reason: 'cap 1/day', delta: '+25', negative: false),
    (
      label: 'Mann Darpan entry',
      reason: '2 of 2 today',
      delta: '+15',
      negative: false,
    ),
    (
      label: 'Yatra lesson 3.2',
      reason: 'lesson complete',
      delta: '+20',
      negative: false,
    ),
    (
      label: 'Shlokas read',
      reason: 'cap 20/day',
      delta: '+18',
      negative: false,
    ),
    (
      label: 'Speed-scroll pause',
      reason: '5 cards under 2 s',
      delta: '0',
      negative: false,
    ),
    (
      label: 'Yesterday\'s Sankalp',
      reason: 'no check-in by midnight',
      delta: '−10',
      negative: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceCanvas,
      appBar: AppBar(
        title: Text(
          'Moksh Points',
          style: AppType.t1.copyWith(color: context.colors.ink),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.s16),
            child: Center(
              child: Text(
                'Rules',
                style: AppType.l1.copyWith(color: context.colors.accentKesar),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.s20,
          AppSpace.s8,
          AppSpace.s20,
          AppSpace.s32,
        ),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSpace.s20),
            decoration: BoxDecoration(
              color: context.colors.field,
              border: Border.all(
                color: context.colors.border,
                width: AppBorder.hairline,
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'LEVEL 2 · SHRAVAK',
                  style: AppType.m1.copyWith(color: context.colors.gold),
                ),
                const SizedBox(height: AppSpace.s8),
                Text(
                  '1,240',
                  style: AppType.d1.copyWith(color: context.colors.gold),
                ),
                const SizedBox(height: AppSpace.s12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: 0.78,
                    minHeight: 8,
                    backgroundColor: context.colors.onField.withValues(
                      alpha: 0.18,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.gold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.s8),
                Text(
                  '260 MP to Sadhak',
                  style: AppType.b3.copyWith(color: context.colors.onField),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s16),
          Row(
            children: <Widget>[
              _Stat(value: '+312', label: 'this week'),
              const SizedBox(width: AppSpace.s8),
              _Stat(value: '2', label: 'Vishram left'),
              const SizedBox(width: AppSpace.s8),
              _Stat(value: '13', label: 'day streak'),
            ],
          ),
          const SizedBox(height: AppSpace.s24),
          Text(
            'TODAY',
            style: AppType.m1.copyWith(color: context.colors.inkMuted),
          ),
          const SizedBox(height: AppSpace.s8),
          PaperPlate(
            shadow: AppShadow.none,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s16),
            child: Column(
              children: <Widget>[
                for (final ({
                      String label,
                      String reason,
                      String delta,
                      bool negative,
                    })
                    row
                    in _today)
                  _LedgerRow(
                    label: row.label,
                    reason: row.reason,
                    delta: row.delta,
                    negative: row.negative,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s16),
          Text(
            'Points pay for depth, never for time. Reading caps at 20 shlokas a '
            'day, and an honest "not today" costs nothing.',
            style: AppType.c1.copyWith(
              color: context.colors.inkMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(
            color: context.colors.border,
            width: AppBorder.hairline,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: AppType.t1.copyWith(color: context.colors.field),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppType.m1.copyWith(
                fontSize: 9,
                color: context.colors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.label,
    required this.reason,
    required this.delta,
    required this.negative,
  });

  final String label;
  final String reason;
  final String delta;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    final Color deltaColor = negative
        ? context.colors.danger
        : delta == '0'
        ? context.colors.inkFaint
        : context.colors.success;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.borderQuiet, width: 1),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: AppType.b2.copyWith(color: context.colors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  reason,
                  style: AppType.c1.copyWith(color: context.colors.inkFaint),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.s12),
          Text(delta, style: AppType.m2.copyWith(color: deltaColor)),
        ],
      ),
    );
  }
}
