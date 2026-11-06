import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../sankalp/sankalp_checkin.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/mp_pill.dart';
import '../../core/widgets/paper_plate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s20,
        AppSpace.s16,
        AppSpace.s20,
        AppSpace.s32,
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.colors.surfaceSunken,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colors.gold,
                  width: AppBorder.b,
                ),
              ),
            ),
            const SizedBox(width: AppSpace.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Kartik',
                    style: AppType.t1.copyWith(color: context.colors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Shravak · joined Nov 2026',
                    style: AppType.b3.copyWith(color: context.colors.inkMuted),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/profile/wallet'),
              child: const MpPill(points: 1240, compact: true),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.s20),
        Row(
          children: <Widget>[
            _Stat(value: '186', label: 'shlokas'),
            const SizedBox(width: AppSpace.s8),
            _Stat(value: '2.4', label: 'chapters'),
            const SizedBox(width: AppSpace.s8),
            _Stat(value: '9', label: 'Sankalps'),
          ],
        ),
        const SizedBox(height: AppSpace.s24),
        Text(
          'BADGES',
          style: AppType.m1.copyWith(color: context.colors.inkMuted),
        ),
        const SizedBox(height: AppSpace.s12),
        Row(
          children: <Widget>[
            _Badge(label: 'Pratham', earned: true),
            _Badge(label: 'Arjuna', earned: true),
            _Badge(label: '7-day', earned: true),
            _Badge(label: '108 Mala', earned: false),
          ],
        ),
        const SizedBox(height: AppSpace.s24),
        PaperPlate(
          shadow: AppShadow.none,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s16),
          child: Column(
            children: <Widget>[
              _Row(
                icon: Icons.check_circle_outline,
                label: 'Aaj ka Sankalp',
                trailing: 'check in',
                onTap: () => showSankalpCheckIn(
                  context,
                  promise: 'I\'ll speak calmly at home tonight.',
                ),
              ),
              _Row(
                icon: Icons.bookmark_border,
                label: 'Saved shlokas',
                trailing: '24',
              ),
              _Row(
                icon: Icons.edit_note,
                label: 'Mann Darpan journal',
                trailing: '11',
              ),
              _Row(
                icon: Icons.show_chart,
                label: 'Mood over time',
                trailing: '',
              ),
              _Row(
                icon: Icons.settings_outlined,
                label: 'Settings · privacy',
                trailing: '',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.s24),
        Text(
          'No ads. No data sold. Ever.',
          textAlign: TextAlign.center,
          style: AppType.c1.copyWith(color: context.colors.inkFaint),
        ),
      ],
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
            width: AppBorder.thin,
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.earned});

  final String label;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: earned
                  ? context.colors.gold
                  : context.colors.surfaceSunken,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.border,
                width: AppBorder.thin,
              ),
            ),
            child: Icon(
              Icons.spa,
              size: 16,
              color: earned ? context.colors.onGold : context.colors.inkFaint,
            ),
          ),
          const SizedBox(height: AppSpace.s4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.m1.copyWith(
              fontSize: 8,
              letterSpacing: 0.2,
              color: earned ? context.colors.ink : context.colors.inkFaint,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.colors.borderQuiet, width: 1),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 18, color: context.colors.inkMuted),
            const SizedBox(width: AppSpace.s12),
            Expanded(
              child: Text(
                label,
                style: AppType.b2.copyWith(color: context.colors.ink),
              ),
            ),
            Text(
              trailing,
              style: AppType.m2.copyWith(color: context.colors.inkMuted),
            ),
            const SizedBox(width: AppSpace.s4),
            Icon(Icons.chevron_right, size: 18, color: context.colors.inkFaint),
          ],
        ),
      ),
    );
  }
}
