import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/settings.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n.dart';

/// A language the app can show, in its own script.
class AppLanguage {
  const AppLanguage(this.name, {this.language});

  /// How the language writes its own name. Never translated.
  final String name;

  /// Null while the language is not ready.
  final Language? language;

  bool get ready => language != null;
}

/// Ready first, then the ones on the way. Each name is in its own script so a
/// person can find theirs without reading English.
const List<AppLanguage> appLanguages = <AppLanguage>[
  AppLanguage('English', language: Language.english),
  AppLanguage('हिन्दी', language: Language.hindi),
  AppLanguage('বাংলা'),
  AppLanguage('मराठी'),
  AppLanguage('తెలుగు'),
  AppLanguage('தமிழ்'),
  AppLanguage('ગુજરાતી'),
  AppLanguage('ಕನ್ನಡ'),
];

/// The name of a ready language in its own script.
String languageNameOf(Language l) => l == Language.hindi ? 'हिन्दी' : 'English';

/// Two large tiles for the languages that work, then a plain list of the ones
/// that are coming. Picking a ready one saves it at once and the app changes.
class LanguageTiles extends ConsumerWidget {
  const LanguageTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final Language chosen = ref.watch(
      settingsProvider.select((Settings s) => s.language),
    );
    final bool hindiChosen = chosen == Language.hindi;
    final SettingsNotifier n = ref.read(settingsProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final AppLanguage l in appLanguages.where(
          (AppLanguage l) => l.ready,
        )) ...<Widget>[
          _LanguageTile(
            name: l.name,
            selected: l.language == Language.hindi ? hindiChosen : !hindiChosen,
            onTap: () => n.setLanguage(l.language!),
          ),
          const SizedBox(height: Sp.s12),
        ],
        const SizedBox(height: Sp.s6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.l.moreLanguages.toUpperCase(),
            style: DType.eyebrow(c.faint),
          ),
        ),
        for (final AppLanguage l in appLanguages.where(
          (AppLanguage l) => !l.ready,
        ))
          _SoonRow(name: l.name),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onTap();
        },
        child: AnimatedContainer(
          duration: Motion.select,
          curve: Motion.easeOut,
          constraints: const BoxConstraints(minHeight: 72),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: Sp.s22,
            vertical: Sp.s14,
          ),
          decoration: BoxDecoration(
            color: selected ? Tok.marigold.withValues(alpha: 0.09) : c.surface,
            borderRadius: BorderRadius.circular(Rad.card),
            border: Border.all(
              color: selected ? Tok.marigold : c.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  name,
                  style: DType.title(c.ink, compact: true).copyWith(
                    // Each name in a font that can draw it.
                    fontFamily: name == 'English'
                        ? DType.serif
                        : DType.serifDeva,
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(width: Sp.s12),
              // A tick, so the choice never rests on colour alone.
              SizedBox(
                width: 28,
                height: 28,
                child: selected
                    ? DIcon('check', size: 28, color: c.accent, glow: true)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A language that is not ready: shown honestly, not tappable.
class _SoonRow extends StatelessWidget {
  const _SoonRow({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      label: context.l.languageSoonSemantic(name),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(vertical: Sp.s12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.line)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                name,
                // Other scripts fall through to the system font for them.
                style: DType.body(c.mute, size: 20),
              ),
            ),
            const SizedBox(width: Sp.s12),
            Flexible(
              child: Text(
                context.l.comingSoon,
                textAlign: TextAlign.end,
                style: DType.body(c.faint, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String textSizeName(BuildContext context, TextSize t) => switch (t) {
  TextSize.normal => context.l.textSizeNormal,
  TextSize.large => context.l.textSizeLarge,
  TextSize.extraLarge => context.l.textSizeExtraLarge,
};

/// Three choices and a line of sample text. The whole app grows as you tap,
/// so the person sees the result at once.
class TextSizeChoice extends ConsumerWidget {
  const TextSizeChoice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final TextSize chosen = ref.watch(
      settingsProvider.select((Settings s) => s.textSize),
    );
    final SettingsNotifier n = ref.read(settingsProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final TextSize t in TextSize.values) ...<Widget>[
          OptionRow(
            label: textSizeName(context, t),
            selected: t == chosen,
            onTap: () => n.setTextSize(t),
          ),
          const SizedBox(height: Sp.s12),
        ],
        const SizedBox(height: Sp.s6),
        DCard(
          child: Text(
            context.l.textSizeSample,
            textAlign: TextAlign.center,
            style: DType.meaning(c.ink),
          ),
        ),
      ],
    );
  }
}
