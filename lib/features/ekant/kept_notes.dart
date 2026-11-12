import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Words from one sitting the user chose to keep, with the verse carried.
@immutable
class KeptNote {
  const KeptNote({
    required this.at,
    required this.words,
    required this.verseId,
  });

  factory KeptNote.fromJson(Map<String, dynamic> j) => KeptNote(
    at: DateTime.parse(j['at'] as String),
    words: (j['words'] as List<dynamic>).cast<String>(),
    verseId: j['verse'] as String,
  );

  final DateTime at;
  final List<String> words;
  final String verseId;

  Map<String, Object> toJson() => <String, Object>{
    'at': at.toIso8601String(),
    'words': words,
    'verse': verseId,
  };
}

/// Kept notes never leave the phone.
abstract interface class KeptNotesStore {
  Future<List<KeptNote>> all();
  Future<void> add(KeptNote note);
  Future<void> remove(DateTime at);
}

/// Encrypted on the device: Android Keystore, iOS Keychain, WebCrypto on web
/// (`flutter_secure_storage`). No backup, no sync.
class SecureKeptNotesStore implements KeptNotesStore {
  SecureKeptNotesStore([FlutterSecureStorage? storage])
    : _s = storage ?? const FlutterSecureStorage();

  static const String _key = 'ekant.kept.v1';
  final FlutterSecureStorage _s;

  @override
  Future<List<KeptNote>> all() async {
    final String? raw = await _s.read(key: _key);
    if (raw == null) return <KeptNote>[];
    return (jsonDecode(raw) as List<dynamic>)
        .map((dynamic e) => KeptNote.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> add(KeptNote note) async =>
      _write(<KeptNote>[...await all(), note]);

  @override
  Future<void> remove(DateTime at) async => _write(<KeptNote>[
    for (final KeptNote n in await all())
      if (n.at != at) n,
  ]);

  Future<void> _write(List<KeptNote> notes) => _s.write(
    key: _key,
    value: jsonEncode(<Object>[for (final KeptNote n in notes) n.toJson()]),
  );
}

/// For tests.
class MemoryKeptNotesStore implements KeptNotesStore {
  final List<KeptNote> notes = <KeptNote>[];

  @override
  Future<List<KeptNote>> all() async => List<KeptNote>.of(notes);

  @override
  Future<void> add(KeptNote note) async => notes.add(note);

  @override
  Future<void> remove(DateTime at) async =>
      notes.removeWhere((KeptNote n) => n.at == at);
}

final Provider<KeptNotesStore> keptNotesStoreProvider =
    Provider<KeptNotesStore>((Ref ref) => SecureKeptNotesStore());
