import 'dart:convert';
import 'dart:io';

import 'package:dharmascroll/app_providers.dart';
import 'package:dharmascroll/core/state/feed.dart';
import 'package:dharmascroll/core/state/progress.dart';
import 'package:dharmascroll/data/verse_repository.dart';
import 'package:dharmascroll/domain/models/verse.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RegExp _devanagari = RegExp(r'^[\u0900-\u097F ]+$');

void main() {
  final String source = File('assets/data/gita_v1.json').readAsStringSync();
  final Map<String, dynamic> doc = jsonDecode(source) as Map<String, dynamic>;
  final Set<String> allowedTags = (doc['tags'] as List<dynamic>)
      .cast<String>()
      .toSet();
  final List<Verse> verses = parseVerses(source);

  test('108 unique verses, ids match chapter.verse, chapters 1..18', () {
    expect(verses, hasLength(108));
    expect(verses.map((Verse v) => v.id).toSet(), hasLength(108));
    for (final Verse v in verses) {
      expect(v.id, '${v.chapter}.${v.number}');
      expect(v.chapter, inInclusiveRange(1, 18));
      expect(v.number, greaterThan(0));
    }
    expect(verses.map((Verse v) => v.chapter).toSet(), hasLength(18));
  });

  test('every verse has real text, valid tags and Devanagari Sanskrit', () {
    for (final Verse v in verses) {
      expect(v.padas, isNotEmpty, reason: v.id);
      for (final String p in v.padas) {
        expect(_devanagari.hasMatch(p), isTrue, reason: '${v.id}: $p');
      }
      expect(v.iast.trim(), isNotEmpty, reason: v.id);
      expect(v.meaningEn.trim(), isNotEmpty, reason: v.id);
      expect(RegExp(r'[\u0900-\u097F]').hasMatch(v.meaningHi), isTrue);
      expect(v.tags.length, inInclusiveRange(3, 5), reason: v.id);
      expect(allowedTags.containsAll(v.tags), isTrue, reason: v.id);
    }
  });

  test('feed gives 5 a day and repeats nothing until all are seen', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime(2026, 11, 1);
    final ProviderContainer c = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        versesProvider.overrideWithValue(verses),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(c.dispose);
    final List<String> seen = <String>[];
    // 21 full days = 105 verses, all distinct.
    for (int day = 0; day < 21; day++) {
      now = DateTime(2026, 11, 1 + day);
      c.invalidate(todayVersesProvider);
      c.invalidate(progressProvider);
      final List<Verse> batch = c.read(todayVersesProvider);
      expect(batch, hasLength(5));
      seen.addAll(batch.map((Verse v) => v.id));
      c.read(progressProvider.notifier).setHeard(5);
    }
    expect(seen.toSet(), hasLength(105));
  });
}
