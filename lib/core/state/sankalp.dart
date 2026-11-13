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
