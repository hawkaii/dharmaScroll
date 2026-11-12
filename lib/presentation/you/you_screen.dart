import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/rituals/providers.dart';
import '../../core/rituals/rituals.dart';
import '../../core/router.dart';
import '../../core/state/progress.dart';
import '../../core/state/settings.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import 'city_picker.dart';

/// You: your light so far, your rituals, and a few settings.
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
            _Row(
              label: 'Ekant',
              value: 'A quiet room',
              onTap: () => context.push(Routes.ekant),
            ),
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
              label: 'Rituals',
              value: '${s.rituals.length} on',
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => const _RitualsSheet(),
              ),
            ),
            _Row(
              label: 'City',
              value: ref.watch(cityProvider)?.name ?? '',
              onTap: () => showDSheet<void>(
                context,
                (BuildContext ctx) => CityPicker(
                  selected: s.cityId,
                  onSelected: (String id) {
                    n.setCity(id);
                    Navigator.of(ctx).pop();
                  },
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

/// The ritual picker: switch rituals on or off, pick a deity day and the
/// Ekadashi rule. Asks to send reminders the first time something goes on.
class _RitualsSheet extends ConsumerWidget {
  const _RitualsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final Settings s = ref.watch(settingsProvider);
    final SettingsNotifier n = ref.read(settingsProvider.notifier);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Text('Your rituals', style: DType.title(c.ink, compact: true)),
          const SizedBox(height: Sp.s12),
          for (final Ritual r in Ritual.values)
            _Row(
              label: r.label,
              trailing: Semantics(
                label: r.label,
                child: Switch(
                  value: s.rituals.contains(r),
                  onChanged: (bool v) {
                    n.setRitual(r, on: v);
                    // The right moment: they just asked for a reminder.
                    if (v) {
                      ref
                          .read(reminderBackendProvider)
                          .requestPermission()
                          .ignore();
                    }
                  },
                ),
              ),
              onTap: () {
                final bool v = !s.rituals.contains(r);
                n.setRitual(r, on: v);
                if (v) {
                  ref
                      .read(reminderBackendProvider)
                      .requestPermission()
                      .ignore();
                }
              },
            ),
          const SizedBox(height: Sp.s18),
          Text('A weekday lamp', style: DType.body(c.mute, size: 17)),
          const SizedBox(height: Sp.s12),
          for (final Deity d in Deity.values) ...<Widget>[
            OptionRow(
              label: d.label,
              selected: d == s.deity,
              onTap: () {
                n.setDeity(d);
                if (d != Deity.none) {
                  ref
                      .read(reminderBackendProvider)
                      .requestPermission()
                      .ignore();
                }
              },
            ),
            const SizedBox(height: Sp.s12),
          ],
          const SizedBox(height: Sp.s6),
          Text('Ekadashi rule', style: DType.body(c.mute, size: 17)),
          const SizedBox(height: Sp.s12),
          for (final Tradition t in Tradition.values) ...<Widget>[
            OptionRow(
              label: t.label,
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
