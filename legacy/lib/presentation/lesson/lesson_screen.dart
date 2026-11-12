import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/progress.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import 'package:lottie/lottie.dart';

import '../../core/widgets/hard_button.dart';
import '../../data/fake_verses.dart';
import '../../domain/models/verse.dart';
import '../../presentation/feed/widgets/checkpoint_card.dart';
import '../../presentation/feed/widgets/expand_sheet.dart';
import '../../presentation/feed/widgets/shloka_card.dart';

/// Chunked 3-5 minute lesson session: 7 cards + a checkpoint every 3.
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late final PageController _controller;
  int _index = 0;

  static const int _cardsPerCheckpoint = 3;
  static const int _totalCards = 7;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isCheckpoint(int page) =>
      page > 0 && (page + 1) % (_cardsPerCheckpoint + 1) == 0;

  int _verseIndexFor(int page) {
    // skip checkpoint slots
    int v = 0;
    for (int i = 0; i <= page; i++) {
      if (!_isCheckpoint(i)) v++;
    }
    return (v - 1).clamp(0, kFakeVerses.length - 1);
  }

  int get _pageCount => _totalCards + (_totalCards ~/ _cardsPerCheckpoint);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: colors.surfaceCanvas,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppSpace.s16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.close, color: colors.ink),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_index + 1) / _pageCount,
                      backgroundColor: colors.surfaceSunken,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpace.s12),
                  Text('${_index + 1}/$_pageCount',
                      style: AppType.m1.copyWith(color: colors.inkMuted)),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                scrollDirection: Axis.vertical,
                physics: const PageScrollPhysics(),
                itemCount: _pageCount,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int page) {
                  if (_isCheckpoint(page)) {
                    return CheckpointCard(
                      onAnswered: (_) {},
                    );
                  }
                  final Verse verse = kFakeVerses[_verseIndexFor(page)];
                  return ShlokaCard(
                    verse: verse,
                    onTap: () => showExpandSheet(context, verse),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpace.s16),
              child: HardButton(
                label: _index == _pageCount - 1 ? 'Finish' : 'Continue',
                onPressed: () {
                  if (_index < _pageCount - 1) {
                    _controller.nextPage(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  } else {
                    ref.read(progressProvider.notifier).completeSession();
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext ctx) => AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Lottie.asset(
                              'assets/lottie/conch.json',
                              width: 96,
                              height: 96,
                              repeat: false,
                            ),
                            const SizedBox(height: AppSpace.s8),
                            Lottie.asset(
                              'assets/lottie/reward_burst.json',
                              width: 96,
                              height: 96,
                              repeat: false,
                            ),
                            const SizedBox(height: AppSpace.s12),
                            Text('Session complete', style: AppType.t1.copyWith(color: context.colors.ink)),
                            Text('+10 MP', style: AppType.m1.copyWith(color: context.colors.gold)),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(onPressed: () { Navigator.of(ctx).pop(); context.pop(); }, child: const Text('Done')),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}