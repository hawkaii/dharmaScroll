import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../domain/models/verse.dart';
import 'progress.dart';

/// Today's five verses. The feed walks the whole list in order and wraps only
/// after every verse has been heard, so nothing repeats until all are seen.
///
/// `feed.start` is where today's batch begins. When the day changes it moves
/// on by the number of verses actually heard that day, so a skipped or
/// half-read day is not lost.
final Provider<List<Verse>> todayVersesProvider = Provider<List<Verse>>((
  Ref ref,
) {
  final List<Verse> all = ref.watch(versesProvider);
  final prefs = ref.watch(sharedPrefsProvider);
  final String today = dayKey(ref.read(clockProvider)());
  int start = prefs.getInt('feed.start') ?? 0;
  final String? day = prefs.getString('feed.day');
  if (day != today) {
    if (day != null && prefs.getString('p.day') == day) {
      start += prefs.getInt('p.heard') ?? 0;
    }
    start %= all.length;
    prefs.setString('feed.day', today);
    prefs.setInt('feed.start', start);
  }
  return <Verse>[
    for (int i = 0; i < ProgressNotifier.dailyVerses; i++)
      all[(start + i) % all.length],
  ];
});
