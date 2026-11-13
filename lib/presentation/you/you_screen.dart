import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_service.dart';
import '../../core/rituals/providers.dart';
import '../../core/rituals/rituals.dart';
import '../../core/router.dart';
import '../../core/state/progress.dart';
import '../../core/state/settings.dart';
import '../../design/info_sheet.dart';
import '../../design/lottie_art.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/auth_words.dart';
import '../../l10n/l10n.dart';
import '../auth/sign_in_panel.dart';
import '../language/language_picker.dart';
import '../onboarding/onboarding_flow.dart' show traditionHint, traditionLabel;
import '../practice/tradition_explainer.dart';
import 'city_picker.dart';

/// You: who you are, your light so far, and five settings, each with one
/// plain line saying what it is for.
class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  /// The language row is the same in every language, so a person who
  /// cannot read the current one can still find it.
  static const String languageRow = 'Language / भाषा';

  static String timeName(int m) => '${_hhmm(m)} ${m < 12 * 60 ? 'AM' : 'PM'}';
  static String _hhmm(int m) {
    final int h = (m ~/ 60) % 12 == 0 ? 12 : (m ~/ 60) % 12;
    return '$h:${(m % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final AppLocalizations l = context.l;
    final Settings s = ref.watch(settingsProvider);
    final ProgressState p = ref.watch(progressProvider);
    final AuthUser? user = ref.watch(authProvider);
    final int on = s.rituals.length + (s.deity == Deity.none ? 0 : 1);
    return Backdrop(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Sp.screenSide,
            Sp.s18,
            Sp.screenSide,
            Sp.s22,
          ),
          children: <Widget>[
            TopLine(left: l.youTitle),
            const SizedBox(height: Sp.s18),
            _Profile(user: user, onTap: () => _account(context)),
            const SizedBox(height: Sp.s22),
            Row(
              children: <Widget>[
                DIcon('lotus', size: 44, color: c.rose, glow: true),
                const SizedBox(width: Sp.s18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l.yourLight,
                        style: DType.title(c.ink, compact: true),
                      ),
                      Text(
                        p.streak <= 1
                            ? l.daysOfLightOne
                            : l.daysOfLight(p.streak),
                        style: DType.body(c.mute, size: 17),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sp.s22),
            Row(
              children: <Widget>[
                Expanded(
                  child: _Tile(
                    icon: 'lotus',
                    iconColor: c.rose,
                    value: '${p.kept.length}',
                    label: l.keptVerses,
                    onTap: () => context.push(Routes.kept),
                  ),
                ),
                const SizedBox(width: Sp.s12),
                Expanded(
                  child: _Tile(
                    icon: 'peacock',
                    iconColor: c.peacock,
                    value: '${p.points}',
                    label: l.mokshPoints,
                    onTap: () => context.push(Routes.wallet),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sp.s12),
            _Row(
              label: l.ekantRow,
              why: l.ekantWhy,
              onTap: () => context.push(Routes.ekant),
            ),
            const SizedBox(height: Sp.s30),
            Text(l.settingsHead, style: DType.eyebrow(c.mute)),
            const SizedBox(height: Sp.s6),
            _Row(
              label: YouScreen.languageRow,
              why: l.languageRowWhy,
              value: languageNameOf(s.language),
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => const _LanguageSheet(),
              ),
            ),
            _Row(
              label: l.textSizeRow,
              why: l.textSizeRowWhy,
              value: textSizeName(context, s.textSize),
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => const _TextSizeSheet(),
              ),
            ),
            _Row(
              label: l.practiceRow,
              why: l.practiceRowWhy,
              value: l.practiceRowValue(on),
              onTap: () => context.push(Routes.practice),
            ),
            _Row(
              label: l.placeRow,
              why: l.placeRowWhy,
              value: ref.watch(cityProvider)?.name,
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => const _PlaceSheet(),
              ),
            ),
            _Row(
              label: l.soundRow,
              why: l.soundRowWhy,
              value: s.sound || s.haptics ? l.on : l.off,
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => const _SoundSheet(),
              ),
            ),
            _Row(
              label: l.lookRow,
              why: l.lookRowWhy,
              value: s.appearance == Appearance.auto
                  ? l.appearanceAuto
                  : l.appearanceNight,
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => const _LookSheet(),
              ),
            ),
            _Row(
              label: l.accountRow,
              why: l.accountRowWhy,
              value: user == null || user.isGuest ? l.guest : l.signedIn,
              onTap: () => _account(context),
            ),
          ],
        ),
      ),
    );
  }

  static void _account(BuildContext context) =>
      showDSheet<void>(context, (BuildContext ctx) => const _AccountSheet());
}

String displayName(AppLocalizations l, AuthUser? u) =>
    u == null || u.name.isEmpty ? l.guest : l.greetingName(u.name);

String methodLine(AppLocalizations l, AuthUser? u) => switch (u?.method) {
  null => l.methodNone,
  SignInMethod.guest => l.methodGuest,
  SignInMethod.google => l.methodGoogle,
  SignInMethod.phone => l.methodPhone(phoneLabel(l, u!.phone)),
};

/// "919876543210" as "+91 98765 43210"; other lengths with a plus in front.
String phoneLabel(AppLocalizations l, String? digits) {
  if (digits == null || digits.isEmpty) return l.phoneWord;
  if (digits.length == 12 && digits.startsWith('91')) {
    return '+91 ${digits.substring(2, 7)} ${digits.substring(7)}';
  }
  return '+$digits';
}

/// Name, how you came in. Tap for the account sheet.
class _Profile extends StatelessWidget {
  const _Profile({required this.user, required this.onTap});

  final AuthUser? user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final AppLocalizations l = context.l;
    final String name = displayName(l, user);
    return Semantics(
      button: true,
      label: '$name. ${methodLine(l, user)}',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.surface,
                  border: Border.all(
                    color: Tok.marigold.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  name.characters.first.toUpperCase(),
                  style: DType.body(c.verse, size: 22).copyWith(height: 1),
                ),
              ),
              const SizedBox(width: Sp.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name, style: DType.body(c.ink, size: 20)),
                    Text(
                      methodLine(l, user),
                      style: DType.body(c.mute, size: 16),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 24, color: c.mute),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small card for your light: an icon, a number, what it counts.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final Color iconColor;
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      button: true,
      label: '$label, $value',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onTap();
        },
        child: DCard(
          padding: const EdgeInsets.fromLTRB(Sp.s18, Sp.s14, Sp.s14, Sp.s14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  DIcon(icon, size: 26, color: iconColor, glow: true),
                  const Spacer(),
                  Icon(Icons.chevron_right, size: 24, color: c.mute),
                ],
              ),
              const SizedBox(height: Sp.s12),
              Text(value, style: DType.hero(c.verse, size: 34)),
              const SizedBox(height: 2),
              Text(label.toUpperCase(), style: DType.ref(c.mute)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A settings row: name, one plain line of why, the current value.
class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.why,
    required this.onTap,
    this.value,
  });

  final String label;
  final String why;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final bool stacked = MediaQuery.textScalerOf(context).scale(1) >= 1.3;
    return Semantics(
      container: true,
      button: true,
      label: <String>[label, ?value, why].join(', '),
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(vertical: Sp.s14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.line)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: DType.body(c.ink, size: 22)),
                    // Big text leaves no room beside the words: the answer
                    // goes under the name instead.
                    if (value != null && stacked)
                      Text(value!, style: DType.body(c.verse, size: 18)),
                    Text(why, style: DType.body(c.mute, size: 16)),
                  ],
                ),
              ),
              if (value != null && !stacked) ...<Widget>[
                const SizedBox(width: Sp.s12),
                // The value is the answer: it gets the strong colour.
                Flexible(
                  child: Text(
                    value!,
                    textAlign: TextAlign.end,
                    style: DType.body(c.verse, size: 18),
                  ),
                ),
              ],
              const SizedBox(width: Sp.s6),
              Icon(Icons.chevron_right, size: 24, color: c.mute),
            ],
          ),
        ),
      ),
    );
  }
}

/// A sheet heading with one line under it.
class _Head extends StatelessWidget {
  const _Head(this.title, this.why);

  final String title;
  final String why;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(title, style: DType.title(c.ink, compact: true)),
        ),
        const SizedBox(height: Sp.s6),
        Text(why, style: DType.body(c.mute, size: 18)),
        const SizedBox(height: Sp.s18),
      ],
    );
  }
}

/// A label with an "i" beside it.
class _Label extends StatelessWidget {
  const _Label(this.text, {this.onInfo});

  final String text;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(text, style: DType.body(context.c.ink, size: 20))),
        if (onInfo != null) InfoButton(topic: text, onTap: onInfo!),
      ],
    );
  }
}

class _PlaceSheet extends ConsumerWidget {
  const _PlaceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Settings s = ref.watch(settingsProvider);
    final SettingsNotifier n = ref.read(settingsProvider.notifier);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _Head(context.l.placeRow, context.l.placeSheetWhy),
          _Label(
            context.l.yourCity,
            onInfo: () => showInfo(
              context,
              title: context.l.whyYourCity,
              art: Art.citySun,
              lines: <String>[context.l.cityInfo1, context.l.cityInfo2],
            ),
          ),
          CityPicker(selected: s.cityId, onSelected: n.setCity),
          const SizedBox(height: Sp.s18),
          _Label(
            context.l.howYouKeepEkadashi,
            onInfo: () => showTraditionExplainer(context),
          ),
          const SizedBox(height: Sp.s12),
          for (final Tradition t in Tradition.values) ...<Widget>[
            OptionRow(
              label: traditionLabel(context.l, t),
              hint: traditionHint(context.l, t),
              selected: t == s.tradition,
              onTap: () => n.setTradition(t),
            ),
            const SizedBox(height: Sp.s12),
          ],
        ],
      ),
    );
  }
}

class _SoundSheet extends ConsumerWidget {
  const _SoundSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final Settings s = ref.watch(settingsProvider);
    final SettingsNotifier n = ref.read(settingsProvider.notifier);
    Widget toggle(
      String label,
      String why,
      bool v,
      ValueChanged<bool> set,
      VoidCallback info,
    ) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => set(!v),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(vertical: Sp.s12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.line)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              // The words are the switch for a screen reader; the "i"
              // stays its own button beside them.
              child: Semantics(
                toggled: v,
                label: '$label. $why',
                excludeSemantics: true,
                onTap: () => set(!v),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: DType.body(c.ink, size: 21)),
                    Text(why, style: DType.body(c.mute, size: 16)),
                  ],
                ),
              ),
            ),
            InfoButton(topic: label, onTap: info),
            ExcludeSemantics(
              child: Switch(value: v, onChanged: set),
            ),
          ],
        ),
      ),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _Head(context.l.soundRow, context.l.soundSheetWhy),
          toggle(
            context.l.soundLabel,
            context.l.soundWhy,
            s.sound,
            n.setSound,
            () => showInfo(
              context,
              title: context.l.soundLabel,
              art: Art.bell,
              lines: <String>[
                context.l.soundInfo1,
                context.l.soundInfo2,
                context.l.soundInfo3,
              ],
            ),
          ),
          toggle(
            context.l.hapticsLabel,
            context.l.hapticsWhy,
            s.haptics,
            n.setHaptics,
            () => showInfo(
              context,
              title: context.l.hapticsLabel,
              art: Art.ripple,
              lines: <String>[context.l.hapticsInfo1, context.l.hapticsInfo2],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pick the app and verse language. Also reachable from the first page of
/// onboarding; the same tiles, saved the moment you tap.
class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _Head(YouScreen.languageRow, context.l.languageSheetWhy),
          const LanguageTiles(),
        ],
      ),
    );
  }
}

class _TextSizeSheet extends StatelessWidget {
  const _TextSizeSheet();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _Head(context.l.textSizeRow, context.l.textSizeSheetWhy),
          const TextSizeChoice(),
        ],
      ),
    );
  }
}

class _LookSheet extends ConsumerWidget {
  const _LookSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = context.l;
    final Settings s = ref.watch(settingsProvider);
    final SettingsNotifier n = ref.read(settingsProvider.notifier);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _Head(l.lookRow, l.lookSheetWhy),
          OptionRow(
            label: l.appearanceAuto,
            hint: l.appearanceAutoHint,
            selected: s.appearance == Appearance.auto,
            onTap: () => n.setAppearance(Appearance.auto),
          ),
          const SizedBox(height: Sp.s12),
          OptionRow(
            label: l.appearanceNight,
            hint: l.appearanceNightHint,
            selected: s.appearance == Appearance.night,
            onTap: () => n.setAppearance(Appearance.night),
          ),
        ],
      ),
    );
  }
}

class _AccountSheet extends ConsumerStatefulWidget {
  const _AccountSheet();

  @override
  ConsumerState<_AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends ConsumerState<_AccountSheet> {
  late final TextEditingController _name = TextEditingController(
    text: ref.read(authProvider)?.name ?? '',
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final AppLocalizations l = context.l;
    final AuthUser? user = ref.watch(authProvider);
    final AuthNotifier auth = ref.read(authProvider.notifier);
    final bool signedIn = user != null && !user.isGuest;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _Head(l.accountRow, l.accountSheetWhy),
          if (user != null) ...<Widget>[
            Text(l.whatToCall, style: DType.body(c.ink, size: 20)),
            Semantics(
              label: l.yourName,
              child: TextField(
                controller: _name,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                style: DType.body(c.ink, size: 20),
                decoration: InputDecoration(
                  hintText: l.yourName,
                  hintStyle: DType.body(c.faint, size: 20),
                  counterText: '',
                ),
                onSubmitted: (String v) => auth.rename(v),
                onChanged: (String v) => auth.rename(v),
              ),
            ),
            const SizedBox(height: Sp.s6),
            Text(methodLine(l, user), style: DType.body(c.mute, size: 16)),
            const SizedBox(height: Sp.s18),
          ],
          if (!signedIn) ...<Widget>[
            Text(l.signInToKeep, style: DType.body(c.mute, size: 18)),
            const SizedBox(height: Sp.s12),
            SignInPanel(allowGuest: false, onDone: () => setState(() {})),
            const SizedBox(height: Sp.s12),
          ],
          _Label(
            l.yourData,
            onInfo: () => showInfo(
              context,
              title: l.whatStaysTitle,
              art: Art.lotusSafe,
              lines: <String>[l.dataInfo1, l.dataInfo2, l.dataInfo3],
            ),
          ),
          Text(l.dataLine, style: DType.body(c.mute, size: 17)),
          if (user != null) ...<Widget>[
            const SizedBox(height: Sp.s12),
            Center(
              child: TextAction(
                label: l.signOut,
                onPressed: () async {
                  await auth.signOut();
                  _name.clear();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
