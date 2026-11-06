import 'package:flutter/material.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/choice_chip_tag.dart';
import '../../core/widgets/hard_button.dart';
import '../../core/widgets/parchment.dart';

/// The day's one promise, made editable before it is made.
///
/// The promise is pre-filled from the verse's Jeevan line, because an empty box
/// is a decision and a filled one is only an edit.
class SankalpScreen extends StatefulWidget {
  const SankalpScreen({super.key, this.prefill});

  final String? prefill;

  @override
  State<SankalpScreen> createState() => _SankalpScreenState();
}

class _SankalpScreenState extends State<SankalpScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.prefill ?? 'I\'ll speak calmly at home tonight.',
  );
  int _remindAt = 21 * 60;

  static const int _maxChars = 80;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceCanvas,
      appBar: AppBar(
        title: Text(
          'Sankalp',
          style: AppType.t1.copyWith(color: context.colors.ink),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.s20),
            child: Center(
              child: Text(
                'Rules',
                style: AppType.l1.copyWith(color: context.colors.accentKesar),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: ParchmentBackground()),
          ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.s20,
              AppSpace.s16,
              AppSpace.s20,
              AppSpace.s32,
            ),
            children: <Widget>[
              Text(
                'Aaj ka Sankalp',
                style: AppType.d2.copyWith(color: context.colors.ink),
              ),
              const SizedBox(height: AppSpace.s6),
              Text(
                'One small promise you can keep today.',
                style: AppType.b3.copyWith(color: context.colors.inkMuted),
              ),
              const SizedBox(height: AppSpace.s20),
              Container(
                padding: const EdgeInsets.all(AppSpace.s20),
                decoration: BoxDecoration(
                  color: context.colors.gold,
                  border: Border.all(
                    color: context.colors.border,
                    width: AppBorder.b,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.auto_awesome,
                          size: 11,
                          color: context.colors.onGold.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: AppSpace.s6),
                        Text(
                          'SANKALP · AAJ',
                          style: AppType.m1.copyWith(
                            color: context.colors.onGold.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s12),
                    TextField(
                      controller: _controller,
                      maxLines: 3,
                      maxLength: _maxChars,
                      onChanged: (_) => setState(() {}),
                      style: AppType.h1.copyWith(
                        color: context.colors.onGold,
                        fontSize: 17,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterStyle: AppType.c1.copyWith(
                          color: context.colors.onGold.withValues(alpha: 0.7),
                        ),
                        hintText: 'Kya aaj karoge?',
                        hintStyle: AppType.h1.copyWith(
                          color: context.colors.onGold.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.s20),
              Text(
                'REMIND ME AT',
                style: AppType.m1.copyWith(color: context.colors.inkMuted),
              ),
              const SizedBox(height: AppSpace.s8),
              Wrap(
                spacing: AppSpace.s8,
                runSpacing: AppSpace.s8,
                children: <Widget>[
                  ChoiceChipTag(
                    label: '6:30 am',
                    selected: _remindAt == 6 * 60 + 30,
                    onTap: () => setState(() => _remindAt = 6 * 60 + 30),
                  ),
                  ChoiceChipTag(
                    label: '9:00 pm',
                    selected: _remindAt == 21 * 60,
                    onTap: () => setState(() => _remindAt = 21 * 60),
                  ),
                  ChoiceChipTag(
                    label: 'No reminder',
                    selected: _remindAt == 0,
                    onTap: () => setState(() => _remindAt = 0),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s24),
              Text(
                'Sach bolne ke points hain. Jhooth ke nahi.',
                style: AppType.b3.copyWith(color: context.colors.inkMuted),
              ),
              const SizedBox(height: AppSpace.s4),
              Text(
                'Done pays 25, partly 10, and an honest "aaj nahi hua" costs nothing.',
                style: AppType.c1.copyWith(
                  color: context.colors.inkFaint,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpace.s32),
              HardButton(
                label: 'Sankalp lein',
                icon: Icons.check,
                block: true,
                onPressed: _controller.text.trim().isEmpty
                    ? null
                    : () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
