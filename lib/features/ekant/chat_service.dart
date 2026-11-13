import 'package:flutter/foundation.dart';

import 'ekant_engine.dart';
import 'ekant_sitting.dart';

/// ChatService: the one seam for Ekant's written replies.
///
/// HOW TO HOOK GEMINI
/// 1. Fill in [GeminiChatService.send] below (see its TODO).
/// 2. In `ekant_providers.dart`, change [chatServiceProvider] to return
///    `GeminiChatService(apiKey: GeminiConfig.apiKey)`. Nothing else changes.
///
/// Rules any implementation must keep (the controller enforces the last two):
/// - Never write as Krishna ("I am Krishna", "I say to you"). Ekant is a room
///   that finds verses; only the verse is the Gita's word.
/// - Never quote or invent scripture in the reply text. Name one verse by id
///   with [ChatVerse]; the app renders it from the local 108 verses.
/// - Crisis words are checked on the phone before [send] is called. A service
///   may also emit [ChatCrisis].
enum ChatRole { user, ekant }

@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.at,
    this.verseId,
    this.lang = EkantLang.en,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
    id: j['id'] as String,
    role: ChatRole.values.byName(j['role'] as String),
    text: j['text'] as String,
    at: DateTime.parse(j['at'] as String),
    verseId: j['verse'] as String?,
    lang: EkantLang.values.byName(j['lang'] as String? ?? 'en'),
  );

  final String id;
  final ChatRole role;
  final String text;
  final DateTime at;

  /// Set on an Ekant reply that carries a verse card.
  final String? verseId;
  final EkantLang lang;

  ChatMessage copyWith({String? text, String? verseId}) => ChatMessage(
    id: id,
    role: role,
    text: text ?? this.text,
    at: at,
    verseId: verseId ?? this.verseId,
    lang: lang,
  );

  Map<String, Object> toJson() => <String, Object>{
    'id': id,
    'role': role.name,
    'text': text,
    'at': at.toIso8601String(),
    'verse': ?verseId,
    'lang': lang.name,
  };
}

/// One piece of a streamed reply.
sealed class ChatChunk {
  const ChatChunk();
}

/// More reply text. Append it to what is already shown.
final class ChatDelta extends ChatChunk {
  const ChatDelta(this.text);
  final String text;
}

/// The one verse this reply points to, by id such as `2.47`. The app checks
/// it exists and may be offered as advice; otherwise the local matcher picks.
final class ChatVerse extends ChatChunk {
  const ChatVerse(this.verseId);
  final String verseId;
}

/// Stop: show the crisis screen. No reply text is shown.
final class ChatCrisis extends ChatChunk {
  const ChatCrisis();
}

abstract interface class ChatService {
  /// [messages] is the whole thread, oldest first; the last one is the new
  /// user message. Send only what the model needs (the app's rule is the new
  /// message plus the last two user turns). Emit [ChatDelta]s, then at most
  /// one [ChatVerse]; closing the stream ends the reply. Errors end the
  /// reply and the room asks the person to try again.
  Stream<ChatChunk> send(List<ChatMessage> messages);
}

/// Where the Gemini key is read from. Pass it at build time:
/// `flutter run --dart-define=GEMINI_API_KEY=...`.
/// shortcut: a key in the app binary can be extracted. Put Gemini behind your
/// own small server before a public release.
abstract final class GeminiConfig {
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static bool get hasKey => apiKey.isNotEmpty;
}

/// Gemini-backed replies. NOT IMPLEMENTED.
class GeminiChatService implements ChatService {
  const GeminiChatService({this.apiKey = GeminiConfig.apiKey});

  final String apiKey;

  @override
  Stream<ChatChunk> send(List<ChatMessage> messages) {
    // TODO(owner): call Gemini streamGenerateContent with [apiKey].
    //  - System prompt: the rules at the top of this file, plus "answer in
    //    the user's language (English, Hindi or Hinglish), 2 to 3 short
    //    sentences, end with one gentle question".
    //  - Ask for the verse as a separate field (JSON `verse_id`), choosing
    //    only from ids you list in the prompt, so no scripture is generated.
    //  - Map each text part to ChatDelta, then ChatVerse(verse_id).
    throw UnimplementedError('GeminiChatService is not hooked up yet');
  }
}

/// Answers from the verses already in the app, with a streaming delay, so the
/// room feels the same as a model-backed one. Wraps the on-phone responder.
class FakeChatService implements ChatService {
  FakeChatService(
    this.responder, {
    this.thinkDelay = const Duration(milliseconds: 1100),
    this.wordDelay = const Duration(milliseconds: 55),
  });

  final EkantResponder responder;

  /// Pause before the first word, while the lamp flickers.
  final Duration thinkDelay;

  /// Pause between words.
  final Duration wordDelay;

  @override
  Stream<ChatChunk> send(List<ChatMessage> messages) async* {
    final List<ChatMessage> said = <ChatMessage>[
      for (final ChatMessage m in messages)
        if (m.role == ChatRole.user) m,
    ];
    if (said.isEmpty) return;
    final int n = said.length;
    final EkantRequest request = EkantRequest(
      text: said.last.text,
      turn: n,
      maxTurns: EkantSitting.maxTurns,
      earlier: <String>[
        for (int i = n < 3 ? 0 : n - 3; i < n - 1; i++) said[i].text,
      ],
      shown: <String>{
        for (final ChatMessage m in messages)
          if (m.verseId != null) m.verseId!,
      },
    );
    await Future<void>.delayed(thinkDelay);
    final EkantReply reply = await responder.respond(request);
    switch (reply) {
      case EkantCrisis():
        yield const ChatCrisis();
      case EkantAnswer():
        final String text = reply.question == null
            ? reply.reflection
            : '${reply.reflection}\n\n${reply.question}';
        for (final RegExpMatch m in RegExp(r'\S+\s*').allMatches(text)) {
          yield ChatDelta(m[0]!);
          await Future<void>.delayed(wordDelay);
        }
        yield ChatVerse(reply.verseId);
    }
  }
}
