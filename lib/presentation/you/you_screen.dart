import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';

import '../../core/state/progress.dart';
import '../../core/state/settings.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';

/// You: your light so far, and five settings. No more.
class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

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
    final SettingsNotifier n = ref.read(settingsProvider.notifier);
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
                        '${p.streak < 1 ? 1 : p.streak} ${p.streak <= 1 ? 'day' : 'days'}  ·  ${p.points} Moksh  ·  ${p.kept.length} kept',
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
              label: 'Reminder',
              value: timeName(s.reminderMinutes),
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => _ReminderSheet(
                  minutes: s.reminderMinutes,
                  onChanged: n.setReminder,
                ),
              ),
            ),
            _Row(
              label: 'Language',
              value: languageName(s.language),
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final Language l in Language.values) ...<Widget>[
                      OptionRow(
                        label: languageName(l),
                        selected: l == s.language,
                        onTap: () {
                          n.setLanguage(l);
                          Navigator.of(ctx).pop();
                        },
                      ),
                      const SizedBox(height: Sp.s12),
                    ],
                  ],
                ),
              ),
            ),
            _Row(
              label: 'Sound & haptics',
              trailing: Semantics(
                label: 'Sound and haptics',
                child: Switch(
                  value: s.soundHaptics,
                  onChanged: (bool v) {
                    n.setSoundHaptics(v);
                  },
                ),
              ),
              onTap: () => n.setSoundHaptics(!s.soundHaptics),
            ),
            _Row(
              label: 'Appearance',
              value: s.appearance == Appearance.auto ? 'Auto' : 'Night',
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    OptionRow(
                      label: 'Auto',
                      selected: s.appearance == Appearance.auto,
                      onTap: () {
                        n.setAppearance(Appearance.auto);
                        Navigator.of(ctx).pop();
                      },
                    ),
                    const SizedBox(height: Sp.s12),
                    OptionRow(
                      label: 'Night',
                      selected: s.appearance == Appearance.night,
                      onTap: () {
                        n.setAppearance(Appearance.night);
                        Navigator.of(ctx).pop();
                      },
                    ),
                    const SizedBox(height: Sp.s12),
                    Text(
                      'Auto brings morning light to Today from 5 to 10.',
                      style: DType.body(c.mute, size: 16),
                    ),
                  ],
                ),
              ),
            ),
            _Row(
              label: 'Privacy & data',
              value: 'Voice not stored',
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Your voice stays with you.',
                      style: DType.title(c.ink, compact: true),
                    ),
                    const SizedBox(height: Sp.s12),
                    Text(
                      'Your progress lives on this phone. Nothing you speak is stored.',
                      style: DType.body(c.mute),
                    ),
                  ],
                ),
              ),
            ),
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

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    this.value,
    this.trailing,
    required this.onTap,
  });

  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      container: true,
      button: true,
      label: value == null ? label : '$label, $value',
      onTap: onTap,
      excludeSemantics: trailing == null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.line)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label, style: DType.body(c.ink, size: 23))),
              if (value != null)
                Text(value!, style: DType.body(c.mute, size: 17)),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderSheet extends StatefulWidget {
  const _ReminderSheet({required this.minutes, required this.onChanged});

  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  late int _m = widget.minutes;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(YouScreen.timeName(_m), style: DType.hero(c.verse, size: 56)),
        Slider(
          min: 4 * 60,
          max: 22 * 60,
          divisions: (18 * 60) ~/ 15,
          value: _m.toDouble(),
          onChanged: (double v) {
            setState(() => _m = v.round());
            widget.onChanged(_m);
          },
        ),
      ],
    );
  }
}
