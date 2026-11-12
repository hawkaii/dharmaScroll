import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_providers.dart';
import '../../domain/models/verse.dart';
import 'progress.dart';

/// One small intention, sealed from a verse, looked back on the next day.
@immutable
class Sankalp {
  const Sankalp({
    required this.day,
    required this.text,
    required this.verseId,
    this.kept,
  });

  /// The day it was sealed, `yyyy-mm-dd`.
  final String day;
  final String text;
  final String verseId;

  /// Null until looked back on. True: kept. False: let go.
  final bool? kept;
}

/// The latest Sankalp only. There is no history to fail against.
class SankalpNotifier extends Notifier<Sankalp?> {
  static const int maxLength = 90;

  SharedPreferences get _p => ref.read(sharedPrefsProvider);

  @override
  Sankalp? build() {
    final SharedPreferences p = ref.watch(sharedPrefsProvider);
    final String? day = p.getString('sk.day');
    final String? text = p.getString('sk.text');
    if (day == null || text == null) return null;
    return Sankalp(
      day: day,
      text: text,
      verseId: p.getString('sk.verse') ?? '',
      kept: p.getBool('sk.kept'),
    );
  }

  String get _today => dayKey(ref.read(clockProvider)());

  /// True when today's Sankalp is already sealed.
  bool get sealedToday => state?.day == _today;

  /// An earlier Sankalp not yet looked back on.
  Sankalp? get waiting {
    final Sankalp? s = state;
    return s != null && s.kept == null && s.day != _today ? s : null;
  }

  void seal(String text, String verseId) {
    final String t = text.trim();
    if (t.isEmpty) return;
    final String clipped = t.length > maxLength ? t.substring(0, maxLength) : t;
    state = Sankalp(day: _today, text: clipped, verseId: verseId);
    _p
      ..setString('sk.day', _today)
      ..setString('sk.text', clipped)
      ..setString('sk.verse', verseId)
      ..remove('sk.kept');
  }

  /// Kept or let go: both are honest answers, so both give the same points.
  int lookBack({required bool kept}) {
    final Sankalp? s = waiting;
    if (s == null) return 0;
    state = Sankalp(day: s.day, text: s.text, verseId: s.verseId, kept: kept);
    _p.setBool('sk.kept', kept);
    return ref
        .read(progressProvider.notifier)
        .award('sankalp', ProgressNotifier.sankalpPoints);
  }
}

final NotifierProvider<SankalpNotifier, Sankalp?> sankalpProvider =
    NotifierProvider<SankalpNotifier, Sankalp?>(SankalpNotifier.new);

/// One small, doable intention per situation tag. Second person, under 12
/// words, no "must".
const Map<String, String> kIntentions = <String, String>{
  'grief': 'Tell one person something you remember with love.',
  'loss': 'Keep one small thing that still connects you.',
  'fear': 'Do the first small part of what you fear.',
  'anxiety': 'Do one task fully, then let the result go.',
  'anger': 'Wait one breath before you answer today.',
  'envy': 'Say one honest good word about someone else.',
  'comparison': 'Notice one thing you did well, without comparing.',
  'pride': 'Ask one person for their advice today.',
  'desire': 'Let one want pass without acting on it.',
  'greed': 'Give one thing away without counting it.',
  'restlessness': 'Sit still for two minutes before your phone.',
  'doubt': 'Take one step before you have every answer.',
  'self-doubt': 'Finish one small thing you said you would.',
  'confusion': 'Write down the one choice that matters today.',
  'loneliness': 'Send one message to someone you miss.',
  'burnout': 'Rest for ten minutes without guilt.',
  'failure': 'Try the thing once more, a little smaller.',
  'success': 'Thank one person who helped you get here.',
  'exam-stress': 'Study one topic fully, then close the book.',
  'work-pressure': 'Do one task fully, without checking the result.',
  'duty-conflict': 'Do the duty in front of you, well.',
  'procrastination': 'Start the task for five minutes only.',
  'perfectionism': 'Finish one thing and let it be enough.',
  'focus': 'Do one thing at a time for an hour.',
  'discipline': 'Keep one small promise to yourself.',
  'habits': 'Do the good habit once, at the same time.',
  'patience': 'Let one thing take the time it takes.',
  'equanimity': 'Meet one good and one hard moment the same.',
  'detachment': 'Do your best and leave the result.',
  'forgiveness': 'Let go of one old hurt, just for today.',
  'compassion': 'Do one quiet kindness no one will see.',
  'kindness': 'Do one quiet kindness no one will see.',
  'gratitude': 'Name three things you are grateful for tonight.',
  'humility': 'Listen fully before you speak, once today.',
  'faith': 'Begin your work with one quiet breath.',
  'surrender': 'Hand one worry over, and do your part.',
  'purpose': 'Do one thing today that matters to you.',
  'mortality': 'Spend ten minutes on what truly matters.',
  'change': 'Welcome one small change without resisting.',
  'self-worth': 'Speak to yourself once as a friend would.',
  'speech': 'Say only what is true and kind today.',
  'contentment': 'Enjoy one simple thing without wanting more.',
  'peace': 'Put the phone down ten minutes before sleep.',
  'hope': 'Do one small thing for tomorrow, tonight.',
  'learning': 'Read one verse again, slowly.',
};

/// The suggested Sankalp for [v]: from its first tag that has one.
String intentionFor(Verse v) {
  for (final String t in v.tags) {
    final String? line = kIntentions[t];
    if (line != null) return line;
  }
  return 'Do one task fully, then let the result go.';
}
