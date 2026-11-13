import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../core/router.dart';
import '../../core/state/progress.dart';
import '../../core/state/settings.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../../l10n/l10n.dart';
import '../hear/hear_screen.dart' show meaningOf;

/// Close or back, top left, for full-screen pages pushed over the tabs.
class BackMark extends StatelessWidget {
  const BackMark({super.key, this.label});

  /// Spoken name; the localized "Back" when null.
  final String? label;

  @override
  Widget build(BuildContext context) {
    void back() => context.canPop() ? context.pop() : context.go(Routes.you);
    return Semantics(
      button: true,
      label: label ?? context.l.back,
      excludeSemantics: true,
      onTap: back,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          back();
        },
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.arrow_back, size: 20, color: context.c.faint),
        ),
      ),
    );
  }
}

/// Kept verses: every verse kept with a double-tap, newest first.
class KeptScreen extends ConsumerWidget {
  const KeptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final List<String> ids = ref
        .watch(progressProvider.select((ProgressState p) => p.kept))
        .toList()
        .reversed
        .toList();
    final Map<String, Verse> byId = <String, Verse>{
      for (final Verse v in ref.watch(versesProvider)) v.id: v,
    };
    final List<Verse> kept = <Verse>[for (final String id in ids) ?byId[id]];
    final Language lang = ref.watch(
      settingsProvider.select((Settings s) => s.language),
    );
    return Scaffold(
      backgroundColor: c.bg,
      body: Backdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Sp.s14,
                  Sp.s6,
                  Sp.screenSide,
                  0,
                ),
                child: Row(
                  children: <Widget>[
                    const BackMark(),
                    Expanded(
                      child: TopLine(
                        left: context.l.keptVerses,
                        right: kept.isEmpty
                            ? null
                            : context.l.keptCount(kept.length),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: kept.isEmpty
                    ? _Empty(c: c)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          Sp.screenSide,
                          Sp.s18,
                          Sp.screenSide,
                          Sp.s30,
                        ),
                        itemCount: kept.length,
                        separatorBuilder: (BuildContext _, int _) =>
                            const SizedBox(height: Sp.s12),
                        itemBuilder: (BuildContext context, int i) => _KeptRow(
                          verse: kept[i],
                          meaning: meaningOf(kept[i], lang),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.c});

  final DharmaColors c;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = context.l;
    return Padding(
      padding: const EdgeInsets.all(Sp.screenSide),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          DIcon('lotus', size: 56, color: c.rose, glow: true),
          const SizedBox(height: Sp.s18),
          Text(l.nothingKept, style: DType.title(c.ink, compact: true)),
          const SizedBox(height: Sp.s12),
          Text(
            l.keptEmptyLine,
            textAlign: TextAlign.center,
            style: DType.body(c.mute),
          ),
        ],
      ),
    );
  }
}

class _KeptRow extends StatelessWidget {
  const _KeptRow({required this.verse, required this.meaning});

  final Verse verse;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    void open() => context.push(Routes.verse(verse.id));
    return Semantics(
      button: true,
      label: '${context.l.gitaRef(verse.id)}. $meaning',
      excludeSemantics: true,
      onTap: open,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          open();
        },
        child: DCard(
          padding: const EdgeInsets.fromLTRB(Sp.s18, Sp.s14, Sp.s14, Sp.s14),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      verse.padas.first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DType.verse(
                        c.verse,
                        size: 18,
                      ).copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meaning,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DType.body(c.mute, size: 16).copyWith(height: 1.3),
                    ),
                    const SizedBox(height: Sp.s6),
                    Text(context.l.gitaRefCaps(verse.id), style: DType.ref(c.faint)),
                  ],
                ),
              ),
              const SizedBox(width: Sp.s12),
              Icon(Icons.chevron_right, size: 20, color: c.faint),
            ],
          ),
        ),
      ),
    );
  }
}
