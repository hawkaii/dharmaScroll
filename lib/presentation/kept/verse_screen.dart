import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/state/settings.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../../features/explain/explain_sheet.dart';
import '../hear/hear_screen.dart' show meaningOf;
import '../share/share_card.dart';
import '../share/share_sheet.dart';
import 'kept_screen.dart' show BackMark;

/// One verse, read slowly: the verse, its meaning, and a quiet "go deeper"
/// with the other language, who speaks, the chapter and where it meets life.
class VerseScreen extends ConsumerWidget {
  const VerseScreen({super.key, required this.id});

  static const String shareLabel = 'Share this verse';

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final List<Verse> all = ref.watch(versesProvider);
    final Verse v = all.firstWhere(
      (Verse x) => x.id == id,
      orElse: () => all.first,
    );
    final Language lang = ref.watch(
      settingsProvider.select((Settings s) => s.language),
    );
    final String meaning = meaningOf(v, lang);
    final bool hindi = lang == Language.hindi;
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
                      child: TopLine(left: 'Gita ${v.id}', right: v.yogaName),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Sp.screenSide,
                    Sp.s30,
                    Sp.screenSide,
                    Sp.s22,
                  ),
                  children: <Widget>[
                    Semantics(
                      label: v.sanskrit.replaceAll('\n', ' '),
                      excludeSemantics: true,
                      child: Column(
                        children: <Widget>[
                          for (final String pada in v.padas)
                            Text(
                              pada,
                              textAlign: TextAlign.center,
                              style: DType.verse(c.verse, size: 23),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Sp.s14),
                    Text(
                      v.iast,
                      textAlign: TextAlign.center,
                      style: DType.translit(c.faint),
                    ),
                    const SizedBox(height: Sp.s30),
                    Text(
                      meaning,
                      textAlign: TextAlign.center,
                      style: DType.meaning(c.ink),
                    ),
                    const SizedBox(height: Sp.s34),
                    Text('GO DEEPER', style: DType.eyebrow(c.accent)),
                    const SizedBox(height: Sp.s12),
                    ExplainLink(verse: v),
                    const SizedBox(height: Sp.s12),
                    _Deeper(
                      label: hindi ? 'In English' : 'In Hindi',
                      text: hindi ? v.meaningEn : v.meaningHi,
                    ),
                    _Deeper(
                      label: 'Who speaks',
                      text: '${v.speaker}, to ${v.listener}.',
                    ),
                    _Deeper(
                      label: 'Where it sits',
                      text: '${v.ref}, ${v.yogaName}.',
                    ),
                    _Deeper(
                      label: 'Where it meets life',
                      text:
                          '${v.tags.map((String t) => t.replaceAll('-', ' ')).join(', ')}.',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Sp.screenSide,
                  Sp.s6,
                  Sp.screenSide,
                  Sp.s14,
                ),
                child: PrimaryButton(
                  label: shareLabel,
                  onPressed: () => showShareSheet(
                    context,
                    ShareContent(verse: v, meaning: meaning),
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

class _Deeper extends StatelessWidget {
  const _Deeper({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Sp.s14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label.toUpperCase(), style: DType.ref(c.faint)),
          const SizedBox(height: Sp.s6),
          Text(text, style: DType.body(c.mute, size: 18)),
        ],
      ),
    );
  }
}
