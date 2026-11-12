import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/models/verse.dart';

const String kVersesAsset = 'assets/data/gita_v1.json';

/// Parses the versioned verse file. Order in the file is the reading order of
/// the feed: the best-loved verses first.
List<Verse> parseVerses(String source) {
  final Map<String, dynamic> doc = jsonDecode(source) as Map<String, dynamic>;
  return (doc['verses'] as List<dynamic>)
      .map((dynamic e) => Verse.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
}

Future<List<Verse>> loadVerses([AssetBundle? bundle]) async =>
    parseVerses(await (bundle ?? rootBundle).loadString(kVersesAsset));
