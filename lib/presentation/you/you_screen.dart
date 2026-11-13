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
import '../auth/sign_in_panel.dart';
import '../onboarding/onboarding_flow.dart' show traditionHint;
import '../practice/tradition_explainer.dart';
import 'city_picker.dart';

/// You: who you are, your light so far, and five settings, each with one
/// plain line saying what it is for.
class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  static const String practiceRow = 'My practice';
  static const String placeRow = 'City and tradition';
  static const String soundRow = 'Sound and touch';
  static const String lookRow = 'Look and language';
  static const String accountRow = 'Account';

  static String languageName(Language l) => switch (l) {
    Language.hindi => 'Hindi',
    Language.english => 'English',
    Language.hinglish => 'Hinglish',
  };

  static String timeName(int m) => '${_hhmm(m)} ${m < 12 * 60 ? 'AM' : 'PM'}';
  static String _hhmm(int m) {
    final int h = (m ~/ 60) % 12 == 0 ? 12 : (m ~/ 60) % 12;
    return '$h:${(m % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
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
            const TopLine(left: 'You'),
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
                        'Your light',
                        style: DType.title(c.ink, compact: true),
                      ),
                      Text(
                        '${p.streak < 1 ? 1 : p.streak} ${p.streak <= 1 ? 'day' : 'days'} of light',
                        style: DType.body(c.mute, size: 16),
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
                    label: 'Kept verses',
                    onTap: () => context.push(Routes.kept),
                  ),
                ),
                const SizedBox(width: Sp.s12),
                Expanded(
                  child: _Tile(
                    icon: 'peacock',
                    iconColor: c.peacock,
                    value: '${p.points}',
                    label: 'Moksh Points',
                    onTap: () => context.push(Routes.wallet),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sp.s12),
            _Row(
              label: 'Ekant',
              why: 'A quiet room to sit with what you feel.',
              onTap: () => context.push(Routes.ekant),
            ),
            const SizedBox(height: Sp.s30),
            Text('SETTINGS', style: DType.eyebrow(c.faint)),
            const SizedBox(height: Sp.s6),
            _Row(
              label: practiceRow,
              why: 'What we remind you of, and when.',
              value: '$on on',
              onTap: () => context.push(Routes.practice),
            ),
            _Row(
              label: placeRow,
              why: 'Your sunrise, and your Ekadashi day.',
              value: ref.watch(cityProvider)?.name,
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => const _PlaceSheet(),
              ),
            ),
            _Row(
              label: soundRow,
              why: 'Soft sounds and small taps you can feel.',
              value: s.sound || s.haptics ? 'On' : 'Off',
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => const _SoundSheet(),
              ),
            ),
            _Row(
              label: lookRow,
              why: 'Night or morning, and your words.',
              value: languageName(s.language),
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => const _LookSheet(),
              ),
            ),
            _Row(
              label: accountRow,
              why: 'Who you are. It stays on this phone.',
              value: user == null || user.isGuest ? 'Guest' : 'Signed in',
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

String displayName(AuthUser? u) =>
    u == null || u.name.isEmpty ? 'Guest' : u.name;

String methodLine(AuthUser? u) => switch (u?.method) {
  null => 'Not signed in',
  SignInMethod.guest => 'Guest on this phone',
  SignInMethod.google => 'Google, on this phone only for now',
  SignInMethod.phone => 'Phone ${u!.phone ?? ''}, on this phone only for now',
};

/// Name, how you came in. Tap for the account sheet.
class _Profile extends StatelessWidget {
  const _Profile({required this.user, required this.onTap});

  final AuthUser? user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final String name = displayName(user);
    return Semantics(
      button: true,
      label: '$name. ${methodLine(user)}',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onTap();
        },
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surface,
                border: Border.all(color: Tok.marigold.withValues(alpha: 0.5)),
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
                  Text(methodLine(user), style: DType.body(c.faint, size: 14)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: c.faint),
          ],
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
                  Icon(Icons.chevron_right, size: 18, color: c.faint),
                ],
              ),
              const SizedBox(height: Sp.s12),
              Text(value, style: DType.hero(c.verse, size: 34)),
              const SizedBox(height: 2),
              Text(label.toUpperCase(), style: DType.ref(c.faint)),
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
                    Text(why, style: DType.body(c.mute, size: 15)),
                  ],
                ),
              ),
              if (value != null) ...<Widget>[
                const SizedBox(width: Sp.s12),
                Text(value!, style: DType.body(c.mute, size: 16)),
              ],
              const SizedBox(width: Sp.s6),
              Icon(Icons.chevron_right, size: 18, color: c.faint),
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
        Text(why, style: DType.body(c.mute, size: 17)),
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
          const _Head(
            YouScreen.placeRow,
            'Your city tells us when the sun rises for you. Prayers follow the sun.',
          ),
          _Label(
            'Your city',
            onInfo: () => showInfo(
              context,
              title: 'Why your city?',
              art: Art.citySun,
              lines: const <String>[
                'The sun rises at a different time in every city.',
                'Sunrise starts each day of the moon. So your city sets the '
                    'right day and hour for every fast and lamp.',
              ],
            ),
          ),
          CityPicker(selected: s.cityId, onSelected: n.setCity),
          const SizedBox(height: Sp.s18),
          _Label(
            'How you keep Ekadashi',
            onInfo: () => showTraditionExplainer(context),
          ),
          const SizedBox(height: Sp.s12),
          for (final Tradition t in Tradition.values) ...<Widget>[
            OptionRow(
              label: t.label,
              hint: traditionHint(t),
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
                    Text(why, style: DType.body(c.mute, size: 15)),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _Head(YouScreen.soundRow, 'Small signs that the app heard you.'),
        toggle(
          'Sound',
          'Soft bells and wood taps.',
          s.sound,
          n.setSound,
          () => showInfo(
            context,
            title: 'Sound',
            art: Art.bell,
            lines: const <String>[
              'When you press a button, you hear a soft tap.',
              'When you finish a step, a small bell rings.',
              'It is always quiet and short. Your phone volume still decides.',
            ],
          ),
        ),
        toggle(
          'Haptics',
          'A tiny tap you feel in your hand.',
          s.haptics,
          n.setHaptics,
          () => showInfo(
            context,
            title: 'Haptics',
            art: Art.ripple,
            lines: const <String>[
              'Haptics means the phone moves a tiny bit, like a soft knock.',
              'You feel it when you pick something or finish a step.',
            ],
          ),
        ),
      ],
    );
  }
}

class _LookSheet extends ConsumerWidget {
  const _LookSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final Settings s = ref.watch(settingsProvider);
    final SettingsNotifier n = ref.read(settingsProvider.notifier);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          const _Head(
            YouScreen.lookRow,
            'How the app looks, and the words it uses.',
          ),
          Text('Language', style: DType.body(c.ink, size: 20)),
          const SizedBox(height: Sp.s12),
          for (final Language l in Language.values) ...<Widget>[
            OptionRow(
              label: YouScreen.languageName(l),
              hint: switch (l) {
                Language.hindi => 'Meanings in Hindi.',
                Language.english => 'Meanings in English.',
                Language.hinglish => 'Hindi words in English letters.',
              },
              selected: l == s.language,
              onTap: () => n.setLanguage(l),
            ),
            const SizedBox(height: Sp.s12),
          ],
          const SizedBox(height: Sp.s6),
          Text('Appearance', style: DType.body(c.ink, size: 20)),
          const SizedBox(height: Sp.s12),
          OptionRow(
            label: 'Auto',
            hint: 'Today turns bright like morning, from 5 to 10.',
            selected: s.appearance == Appearance.auto,
            onTap: () => n.setAppearance(Appearance.auto),
          ),
          const SizedBox(height: Sp.s12),
          OptionRow(
            label: 'Night',
            hint: 'Always the warm dark, all day.',
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
          const _Head(
            YouScreen.accountRow,
            'Who you are here. Your data stays on this phone.',
          ),
          if (user != null) ...<Widget>[
            Text(
              'What should we call you?',
              style: DType.body(c.ink, size: 20),
            ),
            Semantics(
              label: 'Your name',
              child: TextField(
                controller: _name,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                style: DType.body(c.ink, size: 20),
                decoration: InputDecoration(
                  hintText: 'Your name',
                  hintStyle: DType.body(c.faint, size: 20),
                  counterText: '',
                ),
                onSubmitted: (String v) => auth.rename(v),
                onChanged: (String v) => auth.rename(v),
              ),
            ),
            const SizedBox(height: Sp.s6),
            Text(methodLine(user), style: DType.body(c.faint, size: 15)),
            const SizedBox(height: Sp.s18),
          ],
          if (!signedIn) ...<Widget>[
            Text(
              'Sign in to keep your lamp if you change phones.',
              style: DType.body(c.mute, size: 17),
            ),
            const SizedBox(height: Sp.s12),
            SignInPanel(allowGuest: false, onDone: () => setState(() {})),
            const SizedBox(height: Sp.s12),
          ],
          _Label(
            'Your data',
            onInfo: () => showInfo(
              context,
              title: 'What stays with you',
              art: Art.lotusSafe,
              lines: const <String>[
                'Your lamp, your points and your kept verses live on this phone.',
                'Nothing you speak is stored. It is heard, then let go.',
                'Signing in is only pretend for now. Nothing leaves this phone.',
              ],
            ),
          ),
          Text(
            'Your progress lives on this phone. Nothing you speak is stored.',
            style: DType.body(c.mute, size: 16),
          ),
          if (user != null) ...<Widget>[
            const SizedBox(height: Sp.s12),
            Center(
              child: TextAction(
                label: 'Sign out',
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
