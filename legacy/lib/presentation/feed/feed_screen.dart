import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/hard_button.dart';
import '../../core/widgets/mp_pill.dart';
import '../../data/fake_verses.dart';
import '../../domain/models/verse.dart';
import '../mp/daily_reward_sheet.dart';
import 'widgets/coach_marks.dart';
import 'widgets/expand_sheet.dart';
import 'widgets/shloka_card.dart';

enum FeedMode { forYou, kram, topics }

/// The daily ritual: one verse at a time, the replacement for reels muscle
/// memory. Five verses, then a calm end page. There is no "load more".
///
/// Gestures: swipe up for the next verse, double-tap to keep, press and hold
/// to listen (a visual stub this phase; no audio yet), tap to go deeper.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, this.verses = kFakeVerses});

  /// Verses per day. Fixed by product decision, not a setting.
  static const int dailyLimit = 5;

  static const String endTitle = 'That is enough for today.';

  final List<Verse> verses;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PageController _controller = PageController();
  final Set<String> _saved = <String>{};
  final Map<String, int> _awarded = <String, int>{};
  int _page = 0;
  FeedMode _mode = FeedMode.forYou;
  bool _coachVisible = true;
  bool _listening = false;
  bool _keptFlash = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    HapticFeedback.selectionClick();
    setState(() {
      _listening = false;
      _page = page;
      _coachVisible = false;
    });
    // The dwell timer and the +2 award live here in the real build. The card
    // itself never owns a timer: a swipe would leak one per verse.
  }

  void _toggleSave(Verse verse) {
    setState(() {
      if (_saved.contains(verse.id)) {
        _saved.remove(verse.id);
      } else {
        _saved.add(verse.id);
        _awarded[verse.id] = (_awarded[verse.id] ?? 0) + 2;
      }
    });
  }

  /// Double-tap keeps; it never un-keeps, so a nervous second double-tap is
  /// harmless. Un-keeping stays on the rail's Save toggle.
  Future<void> _keep(Verse verse) async {
    HapticFeedback.lightImpact();
    if (!_saved.contains(verse.id)) {
      _toggleSave(verse);
    }
    setState(() => _keptFlash = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _keptFlash = false);
    }
  }

  void _setListening(bool value) {
    if (value) {
      HapticFeedback.selectionClick();
    }
    setState(() => _listening = value);
  }

  @override
  Widget build(BuildContext context) {
    final List<Verse> verses = widget.verses
        .take(FeedScreen.dailyLimit)
        .toList(growable: false);
    // The coach plate is optional teaching, and at 200% text it would take more
    // vertical space than the shloka it explains. Drop it rather than shrink it.
    final bool showCoach =
        _coachVisible && MediaQuery.textScalerOf(context).scale(1) <= 1.5;

    return DecoratedBox(
      decoration: BoxDecoration(color: context.colors.surfaceCanvas),
      child: Column(
        children: <Widget>[
          _FeedHeader(
            mode: _mode,
            page: _page < verses.length ? _page : verses.length - 1,
            total: verses.length,
            onMode: (FeedMode mode) => setState(() => _mode = mode),
            onStreakTap: () => showDailyRewardSheet(context),
          ),
          if (showCoach)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.s8),
              child: CoachMarks(
                onDismiss: () => setState(() => _coachVisible = false),
              ),
            ),
          Expanded(
            child: Stack(
              children: <Widget>[
                PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  physics: const PageScrollPhysics(),
                  allowImplicitScrolling: true,
                  // The verses, then the end page. Nothing after it.
                  itemCount: verses.length + 1,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == verses.length) {
                      return const _EnoughForToday();
                    }
                    final Verse verse = verses[index];
                    return GestureDetector(
                      key: ValueKey<String>(verse.id),
                      behavior: HitTestBehavior.translucent,
                      onDoubleTap: () => _keep(verse),
                      onLongPressStart: (_) => _setListening(true),
                      onLongPressEnd: (_) => _setListening(false),
                      onLongPressCancel: () => _setListening(false),
                      child: ShlokaCard(
                        verse: verse,
                        saved: _saved.contains(verse.id),
                        awarded: _awarded[verse.id] ?? 0,
                        onSave: () => _toggleSave(verse),
                        onShare: () => context.push('/share-card/${verse.id}'),
                        onDeepen: () => _openSheet(verse),
                        onTap: () => _openSheet(verse),
                      ),
                    );
                  },
                ),
                _ListeningGlow(visible: _listening),
                _KeptToast(visible: _keptFlash),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Any deliberate interaction retires the coach marks — they explain the
  /// gestures, so using a gesture is the signal that they have been read.
  void _openSheet(Verse verse) {
    if (_coachVisible) {
      setState(() => _coachVisible = false);
    }
    showExpandSheet(context, verse);
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({
    required this.mode,
    required this.page,
    required this.total,
    required this.onMode,
    required this.onStreakTap,
  });

  final FeedMode mode;
  final int page;
  final int total;
  final ValueChanged<FeedMode> onMode;
  final VoidCallback onStreakTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s20,
        AppSpace.s8,
        AppSpace.s12,
        AppSpace.s8,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                // Horizontal scroll rather than shrinking: Hinglish labels run
                // 30% longer than English and 200% text scale doubles them
                // again. A clipped tab is better than an overflowing one.
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      _ModeTab(
                        label: 'For You',
                        active: mode == FeedMode.forYou,
                        onTap: () => onMode(FeedMode.forYou),
                      ),
                      const SizedBox(width: AppSpace.s12),
                      _ModeTab(
                        label: 'Kram',
                        active: mode == FeedMode.kram,
                        onTap: () => onMode(FeedMode.kram),
                      ),
                      const SizedBox(width: AppSpace.s12),
                      _ModeTab(
                        label: 'Topics',
                        active: mode == FeedMode.topics,
                        onTap: () => onMode(FeedMode.topics),
                      ),
                    ],
                  ),
                ),
              ),
              // PDF §11: Library is reached from the feed's top bar.
              IconButton(
                onPressed: () => context.push('/library'),
                icon: const Icon(Icons.search, size: 20),
                color: context.colors.ink,
                tooltip: 'Search the library',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => context.push('/library'),
                icon: const Icon(Icons.menu_book_outlined, size: 20),
                color: context.colors.ink,
                tooltip: 'Library',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.s8),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.local_fire_department,
                  size: 15,
                  color: context.colors.accentKesar,
                ),
                const SizedBox(width: AppSpace.s4),
                Text(
                  '12',
                  style: AppType.m2.copyWith(color: context.colors.ink),
                ),
                const SizedBox(width: AppSpace.s12),
                Flexible(
                  child: Text(
                    '${page + 1} of $total',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.m1.copyWith(
                      color: context.colors.inkMuted,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                const MpPill(points: 1240),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s6),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: AppType.l1.copyWith(
                color: active ? context.colors.ink : context.colors.inkMuted,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: AppMotion.resolve(context, AppMotion.fast),
              height: 3,
              width: active ? 26 : 0,
              color: context.colors.accentKesar,
            ),
          ],
        ),
      ),
    );
  }
}

/// Hold-to-listen stub: a glow rising from the bottom while the finger is down.
/// Chant playback and word highlighting land with the audio phase.
class _ListeningGlow extends StatelessWidget {
  const _ListeningGlow({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: AppMotion.resolve(context, AppMotion.sheet),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 1.1),
                radius: 0.9,
                colors: <Color>[
                  context.colors.accentKesar.withValues(alpha: 0.28),
                  context.colors.accentKesar.withValues(alpha: 0),
                ],
              ),
            ),
            child: Align(
              alignment: const Alignment(0, 0.92),
              child: Semantics(
                liveRegion: true,
                label: visible ? 'Listening' : null,
                child: Text(
                  'LISTENING',
                  style: AppType.m1.copyWith(
                    color: context.colors.accentKesar,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeptToast extends StatelessWidget {
  const _KeptToast({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: AppSpace.s64,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: AppMotion.resolve(context, AppMotion.fast),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s16,
                vertical: AppSpace.s8,
              ),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border.all(color: context.colors.accentKesar),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'KEPT',
                style: AppType.m1.copyWith(color: context.colors.accentKesar),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The end of the day's feed. Two ways out: walk the next step, or rest.
class _EnoughForToday extends StatelessWidget {
  const _EnoughForToday();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpace.s24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - AppSpace.s48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ExcludeSemantics(
                  child: Text(
                    'ॐ',
                    style: AppType.sktL.copyWith(
                      fontSize: 54,
                      color: context.colors.accentKesar,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.s24),
                Semantics(
                  header: true,
                  child: Text(
                    FeedScreen.endTitle,
                    textAlign: TextAlign.center,
                    style: AppType.d3.copyWith(color: context.colors.ink),
                  ),
                ),
                const SizedBox(height: AppSpace.s12),
                Text(
                  'The verse will wait.',
                  textAlign: TextAlign.center,
                  style: AppType.b1.copyWith(color: context.colors.inkMuted),
                ),
                const SizedBox(height: AppSpace.s40),
                HardButton(
                  label: 'Walk the next step',
                  block: true,
                  variant: HardButtonVariant.gold,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push(Routes.lesson);
                  },
                ),
                const SizedBox(height: AppSpace.s8),
                HardButton(
                  label: 'Rest for now',
                  block: true,
                  variant: HardButtonVariant.ghost,
                  onPressed: () => context.go(Routes.today),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
