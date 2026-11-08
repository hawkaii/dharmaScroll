import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/mp_pill.dart';
import '../../data/fake_verses.dart';
import '../../domain/models/verse.dart';
import '../mp/daily_reward_sheet.dart';
import 'widgets/checkpoint_card.dart';
import 'widgets/coach_marks.dart';
import 'widgets/expand_sheet.dart';
import 'widgets/shloka_card.dart';

enum FeedMode { forYou, kram, topics }

/// The daily ritual: one verse at a time, the replacement for reels muscle
/// memory.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

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

  /// The checkpoint lands after the seventh verse, never as a full-screen
  /// interruption — it is one page in the sequence, swipable like any other.
  static const int _checkpointAt = 7;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
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

  @override
  Widget build(BuildContext context) {
    final List<Verse> verses = kFakeVerses;
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
            page: _page,
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
                  itemCount: verses.length + 1,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == _checkpointAt) {
                      return const CheckpointCard();
                    }
                    final Verse verse =
                        verses[index < _checkpointAt ? index : index - 1];
                    return ShlokaCard(
                      key: ValueKey<String>(verse.id),
                      verse: verse,
                      saved: _saved.contains(verse.id),
                      awarded: _awarded[verse.id] ?? 0,
                      onSave: () => _toggleSave(verse),
                      onShare: () => context.push('/share-card/${verse.id}'),
                      onDeepen: () => _openSheet(verse),
                      onTap: () => _openSheet(verse),
                    );
                  },
                ),
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
                    'Nitya ${page + 1}/$total',
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
