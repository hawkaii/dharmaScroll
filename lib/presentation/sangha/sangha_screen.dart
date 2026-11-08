import 'package:flutter/material.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/hard_button.dart';
import '../../core/widgets/paper_plate.dart';

/// Sangha ships as an honest empty room.
///
/// No invented leaderboard, no "4,210 seekers joined". If there are no players,
/// the screen says so — that is a product rule, not a launch limitation.
class SanghaScreen extends StatelessWidget {
  const SanghaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s20,
        AppSpace.s16,
        AppSpace.s20,
        AppSpace.s24,
      ),
      child: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Sangha',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.t1.copyWith(color: context.colors.ink),
                ),
              ),
              const SizedBox(width: AppSpace.s8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.inkMuted, width: 1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'V0.2',
                  style: AppType.m1.copyWith(
                    fontSize: 9,
                    color: context.colors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s20),
          PaperPlate(
            shadow: AppShadow.none,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'League abhi band hai.',
                  style: AppType.t2.copyWith(color: context.colors.ink),
                ),
                const SizedBox(height: AppSpace.s8),
                Text(
                  'Hum sacche logon ke saath hi kholenge — nakli leaderboard '
                  'nahi banayenge.',
                  style: AppType.b2.copyWith(color: context.colors.inkMuted),
                ),
                const SizedBox(height: AppSpace.s12),
                Text(
                  'We won\'t invent players to fill a table.',
                  style: AppType.b3.copyWith(
                    color: context.colors.inkFaint,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s24),
          Text(
            'YOUR WEEK',
            style: AppType.m1.copyWith(color: context.colors.inkMuted),
          ),
          const SizedBox(height: AppSpace.s8),
          Row(
            children: <Widget>[
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Container(
                    height: 42,
                    margin: const EdgeInsets.only(right: AppSpace.s6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i < 5
                          ? context.colors.gold
                          : context.colors.surfaceSunken,
                      border: Border.all(
                        color: context.colors.border,
                        width: i < 5 ? AppBorder.hairline : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      const <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                      style: AppType.m1.copyWith(
                        fontSize: 10,
                        letterSpacing: 0.2,
                        color: i < 5
                            ? context.colors.onGold
                            : context.colors.inkFaint,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.s32),
          HardButton(
            label: 'Invite a Sakha',
            icon: Icons.person_add_alt,
            block: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
