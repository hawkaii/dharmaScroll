import 'package:flutter/material.dart';

import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_type.dart';
import '../../../core/theme/theme_x.dart';
import '../../../core/widgets/fitted_padas.dart';
import '../../../core/widgets/parchment.dart';
import '../../../domain/models/verse.dart';

/// The atomic unit of the product: one verse, full screen, nothing competing.
///
/// The card carries a border but never a shadow — it is a reading surface, not
/// an object you can lift. Everything tappable sits in the rail or the hint.
class ShlokaCard extends StatelessWidget {
  const ShlokaCard({
    super.key,
    required this.verse,
    this.saved = false,
    this.onSave,
    this.onShare,
    this.onDeepen,
    this.onTap,
    this.awarded = 0,
    this.reason,
  });

  final Verse verse;
  final bool saved;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onDeepen;
  final VoidCallback? onTap;

  /// Session-local points for this card. Deliberately not the global balance:
  /// a card that watched the ledger would re-lay-out the Devanagari on every
  /// award.
  final int awarded;

  /// Why this verse is here — "FOR YOU · ANGER", "KRAM · 2.47".
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final bool compact = width < 380 || scaler.scale(28) > 34;

    // At normal sizes the content fits, so the card must not own a vertical
    // scrollable: a nested scroll view swallows the page swipe and the feed
    // stops turning. Only when the text is genuinely enlarged does the verse
    // scroll inside the card.
    final ScrollPhysics physics = scaler.scale(1) > 1.2
        ? const ClampingScrollPhysics()
        : const NeverScrollableScrollPhysics();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ParchmentBackground(
            child: Align(
              alignment: const Alignment(0, -0.15),
              child: VerseOrnament(
                verseId: verse.id,
                size: compact ? 190 : 240,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              _CardHeader(verse: verse, reason: reason),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      physics: physics,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.s24,
                        AppSpace.s8,
                        AppSpace.s24 + 44,
                        AppSpace.s24,
                      ),
                      // Fill the viewport so a short shloka sits optically
                      // centred instead of hugging the header.
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - AppSpace.s32,
                        ),
                        child: _CardBody(verse: verse, compact: compact),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: AppSpace.s8,
            bottom: AppSpace.s24,
            child: _CardRail(
              verse: verse,
              saved: saved,
              awarded: awarded,
              onSave: onSave,
              onShare: onShare,
              onDeepen: onDeepen,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.verse, this.reason});

  final Verse verse;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final String label =
        reason ??
        'ADHYAY ${verse.chapter} · ${verse.yogaName.toUpperCase()} · SHLOKA ${verse.number}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s24,
        AppSpace.s16,
        AppSpace.s16,
        AppSpace.s4,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.m1.copyWith(
                color: context.colors.inkMuted,
                fontSize: 10,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.verse, required this.compact});

  final Verse verse;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Never let a 2.0x reader push the shloka past the fold and clip it.
        // The verse scrolls; the meaning below still scales fully.
        MediaQuery.withClampedTextScaling(
          minScaleFactor: 1,
          maxScaleFactor: 1.8,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
            child: FittedPadas(padas: verse.padas, color: context.colors.field),
          ),
        ),
        const SizedBox(height: AppSpace.s16),
        Text(
          verse.iast,
          textAlign: TextAlign.center,
          style: AppType.iast.copyWith(color: context.colors.inkMuted),
        ),
        const SizedBox(height: AppSpace.s20),
        Text(
          verse.meaningHi,
          textAlign: TextAlign.center,
          style: AppType.hiRead.copyWith(color: context.colors.ink),
        ),
        const SizedBox(height: AppSpace.s8),
        Text(
          verse.meaningEn,
          textAlign: TextAlign.center,
          style: AppType.b3.copyWith(
            color: context.colors.inkMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpace.s24),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s12,
              vertical: AppSpace.s8,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface.withValues(alpha: 0.7),
              border: Border.all(
                color: context.colors.border,
                width: AppBorder.hairline,
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              'Tap to go deeper',
              style: AppType.l1.copyWith(
                color: context.colors.ink,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardRail extends StatelessWidget {
  const _CardRail({
    required this.verse,
    required this.saved,
    required this.awarded,
    this.onSave,
    this.onShare,
    this.onDeepen,
  });

  final Verse verse;
  final bool saved;
  final int awarded;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onDeepen;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _RailItem(
          icon: saved ? Icons.bookmark : Icons.bookmark_border,
          label: saved ? 'Saved' : 'Save',
          active: saved,
          onTap: onSave,
        ),
        _RailItem(icon: Icons.north_east, label: 'Share', onTap: onShare),
        _RailItem(
          icon: Icons.auto_stories_outlined,
          label: 'Deepen',
          onTap: onDeepen,
        ),
        const SizedBox(height: AppSpace.s8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s8,
            vertical: AppSpace.s4,
          ),
          decoration: BoxDecoration(
            color: context.colors.field,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            awarded > 0 ? '+$awarded' : '+2',
            style: AppType.m1.copyWith(
              color: context.colors.onField,
              fontSize: 10,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color tint = active ? context.colors.ink : context.colors.inkMuted;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.s6),
          child: SizedBox(
            width: 44,
            child: Column(
              children: <Widget>[
                Icon(icon, size: 21, color: tint),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppType.m1.copyWith(
                    color: tint,
                    fontSize: 8,
                    letterSpacing: 0.2,
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
