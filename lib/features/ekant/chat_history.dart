import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'chat_service.dart';

/// The written thread, kept on this phone until the person lets it fade.
abstract interface class ChatHistoryStore {
  Future<List<ChatMessage>> load();
  Future<void> save(List<ChatMessage> messages);
  Future<void> clear();
}

/// Encrypted on the device, like kept notes. No backup, no sync.
class SecureChatHistoryStore implements ChatHistoryStore {
  SecureChatHistoryStore([FlutterSecureStorage? storage])
    : _s = storage ?? const FlutterSecureStorage();

  static const String _key = 'ekant.chat.v1';
  final FlutterSecureStorage _s;

  @override
  Future<List<ChatMessage>> load() async {
    try {
      final String? raw = await _s.read(key: _key);
      if (raw == null) return <ChatMessage>[];
      return (jsonDecode(raw) as List<dynamic>)
          .map((dynamic e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // An unreadable thread is dropped rather than blocking the room.
      return <ChatMessage>[];
    }
  }

  @override
  Future<void> save(List<ChatMessage> messages) => _s.write(
    key: _key,
    value: jsonEncode(<Object>[
      for (final ChatMessage m in messages) m.toJson(),
    ]),
  );

  @override
  Future<void> clear() => _s.delete(key: _key);
}

/// For tests.
class MemoryChatHistoryStore implements ChatHistoryStore {
  List<ChatMessage> messages = <ChatMessage>[];

  @override
  Future<List<ChatMessage>> load() async => List<ChatMessage>.of(messages);

  @override
  Future<void> save(List<ChatMessage> m) async =>
      messages = List<ChatMessage>.of(m);

  @override
  Future<void> clear() async => messages = <ChatMessage>[];
}

final Provider<ChatHistoryStore> chatHistoryStoreProvider =
    Provider<ChatHistoryStore>((Ref ref) => SecureChatHistoryStore());
