import 'package:flutter/material.dart';

import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_type.dart';
import '../../../core/theme/theme_x.dart';
import '../../../domain/models/verse.dart';

/// Opens the three-tab depth sheet.
///
/// Imperative rather than routed: it is a transient view over one card, the
/// back gesture and barrier come free, and there is nothing to deep-link to
/// that the verse screen does not already show.
Future<void> showExpandSheet(BuildContext context, Verse verse) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.colors.scrim,
    builder: (BuildContext ctx) => ExpandSheet(verse: verse),
  );
}

enum _SheetTab { shabdarth, katha, jeevan }

class ExpandSheet extends StatefulWidget {
  const ExpandSheet({super.key, required this.verse});

  final Verse verse;

  @override
  State<ExpandSheet> createState() => _ExpandSheetState();
}

class _ExpandSheetState extends State<ExpandSheet> {
  _SheetTab _tab = _SheetTab.shabdarth;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      snap: true,
      snapSizes: const <double>[0.62, 0.94],
      builder: (BuildContext ctx, ScrollController controller) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border.all(
              color: context.colors.border,
              width: AppBorder.b,
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: AppSpace.s12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.ink.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              _SheetHeader(verse: widget.verse),
              _SheetTabBar(
                current: _tab,
                onChanged: (_SheetTab tab) => setState(() => _tab = tab),
              ),
              Expanded(
                child: CustomScrollView(
                  controller: controller,
                  slivers: <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.s20,
                        AppSpace.s16,
                        AppSpace.s20,
                        AppSpace.s32,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(_children(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _children(BuildContext context) {
    switch (_tab) {
      case _SheetTab.shabdarth:
        return <Widget>[
          for (final WordMeaning word in widget.verse.wordMeanings)
            _WordRow(word: word),
          const SizedBox(height: AppSpace.s16),
          _InsetBlock(label: 'Anvaya', body: widget.verse.iast),
        ];
      case _SheetTab.katha:
        return <Widget>[
          _InsetBlock(
            label: 'Who is speaking',
            body: '${widget.verse.speaker} to ${widget.verse.listener}',
          ),
          const SizedBox(height: AppSpace.s16),
          Text(
            widget.verse.context,
            style: AppType.b1.copyWith(color: context.colors.ink),
          ),
          const SizedBox(height: AppSpace.s16),
          Container(
            padding: const EdgeInsets.only(left: AppSpace.s12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: context.colors.field,
                  width: AppBorder.thin,
                ),
              ),
            ),
            child: Text(
              widget.verse.meaningHi,
              style: AppType.hiRead.copyWith(color: context.colors.ink),
            ),
          ),
        ];
      case _SheetTab.jeevan:
        return <Widget>[
          Text(
            widget.verse.lessonHi,
            style: AppType.hiRead.copyWith(color: context.colors.ink),
          ),
          const SizedBox(height: AppSpace.s16),
          Text(
            widget.verse.lessonEn,
            style: AppType.b2.copyWith(color: context.colors.inkMuted),
          ),
          const SizedBox(height: AppSpace.s24),
          Container(
            padding: const EdgeInsets.all(AppSpace.s16),
            decoration: BoxDecoration(
              color: context.colors.gold,
              border: Border.all(
                color: context.colors.border,
                width: AppBorder.b,
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: context.colors.onGold,
                ),
                const SizedBox(width: AppSpace.s8),
                Expanded(
                  child: Text(
                    'Make this my Sankalp',
                    style: AppType.h1.copyWith(color: context.colors.onGold),
                  ),
                ),
              ],
            ),
          ),
        ];
    }
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.verse});

  final Verse verse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s20,
        AppSpace.s16,
        AppSpace.s20,
        AppSpace.s8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'ADHYAY ${verse.chapter} · ${verse.yogaName.toUpperCase()} · ${verse.number}',
                  style: AppType.m1.copyWith(color: context.colors.inkMuted),
                ),
                const SizedBox(height: AppSpace.s4),
                Text(
                  verse.padas.first.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.sktS.copyWith(color: context.colors.field),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.s12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s8,
              vertical: AppSpace.s4,
            ),
            decoration: BoxDecoration(
              color: context.colors.field,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              '+3',
              style: AppType.m1.copyWith(
                color: context.colors.gold,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTabBar extends StatelessWidget {
  const _SheetTabBar({required this.current, required this.onChanged});

  final _SheetTab current;
  final ValueChanged<_SheetTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s20,
        vertical: AppSpace.s8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (final _SheetTab tab in _SheetTab.values)
              Padding(
                padding: const EdgeInsets.only(right: AppSpace.s8),
                child: GestureDetector(
                  onTap: () => onChanged(tab),
                  child: AnimatedContainer(
                    duration: AppMotion.resolve(context, AppMotion.fast),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s12,
                      vertical: AppSpace.s8,
                    ),
                    decoration: BoxDecoration(
                      color: current == tab
                          ? context.colors.field
                          : context.colors.surfaceRaised,
                      border: Border.all(
                        color: context.colors.border,
                        width: AppBorder.thin,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      switch (tab) {
                        _SheetTab.shabdarth => 'SHABDARTH',
                        _SheetTab.katha => 'KATHA',
                        _SheetTab.jeevan => 'JEEVAN',
                      },
                      maxLines: 1,
                      style: AppType.m1.copyWith(
                        fontSize: 10,
                        letterSpacing: 0.8,
                        color: current == tab
                            ? context.colors.onField
                            : context.colors.inkMuted,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({required this.word});

  final WordMeaning word;

  @override
  Widget build(BuildContext context) {
    final bool stacked = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    final Widget wordText = Text(
      word.word,
      style: AppType.sktS.copyWith(color: context.colors.field),
    );
    final Widget hindiText = Text(
      word.meaningHi,
      style: AppType.hiUi.copyWith(color: context.colors.ink),
    );
    final Widget englishText = Text(
      word.meaningEn,
      style: AppType.b3.copyWith(color: context.colors.inkMuted),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.borderQuiet, width: 1),
        ),
      ),
      child: stacked
          // At large text three columns become unreadable; stack instead of
          // clipping a meaning.
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                wordText,
                const SizedBox(height: AppSpace.s4),
                hindiText,
                const SizedBox(height: AppSpace.s2),
                englishText,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                SizedBox(width: 110, child: wordText),
                Expanded(child: hindiText),
                const SizedBox(width: AppSpace.s8),
                Flexible(child: englishText),
              ],
            ),
    );
  }
}

class _InsetBlock extends StatelessWidget {
  const _InsetBlock({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.s16),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        border: Border.all(color: context.colors.borderQuiet, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: AppType.m1.copyWith(color: context.colors.inkMuted),
          ),
          const SizedBox(height: AppSpace.s8),
          Text(body, style: AppType.b2.copyWith(color: context.colors.ink)),
        ],
      ),
    );
  }
}
