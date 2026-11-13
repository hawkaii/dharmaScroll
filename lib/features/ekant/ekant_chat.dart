import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/verse.dart';
import 'chat_history.dart';
import 'chat_service.dart';
import 'ekant_engine.dart';
import 'ekant_sitting.dart';

enum SendResult { sent, crisis, failed, ignored }

/// The written thread: what was said, the reply being streamed, and the
/// rules around them (crisis check on the phone first, verse checked against
/// the local verses, eight turns to a sitting). Talks to a [ChatService] and
/// keeps the thread in a [ChatHistoryStore].
class EkantChat extends ChangeNotifier {
  EkantChat({
    required this.service,
    required this.store,
    required this.matcher,
    required this.clock,
  });

  final ChatService service;
  final ChatHistoryStore store;
  final VerseMatcher matcher;
  final DateTime Function() clock;

  final List<ChatMessage> _messages = <ChatMessage>[];
  ChatMessage? _pending;
  bool _busy = false;
  bool _waiting = false;
  bool _disposed = false;
  int _seq = 0;

  /// The thread as shown, including a reply that is still arriving.
  List<ChatMessage> get messages => <ChatMessage>[..._messages, ?_pending];

  /// A reply is on its way (waiting or streaming).
  bool get busy => _busy;

  /// A reply is on its way but no word has come yet: the lamp flickers.
  bool get waiting => _waiting;

  /// True while the last message is a reply still being written.
  bool get streaming => _pending != null;

  bool get isEmpty => _messages.isEmpty;

  int get userCount =>
      _messages.where((ChatMessage m) => m.role == ChatRole.user).length;

  /// No more turns: the room only offers rest.
  bool get full => userCount >= EkantSitting.maxTurns;

  Future<void> load() async {
    try {
      final List<ChatMessage> saved = await store.load();
      if (_disposed || _messages.isNotEmpty) return;
      _messages.addAll(saved);
      notifyListeners();
    } catch (e) {
      debugPrint('EkantChat.load: $e');
    }
  }

  String _id() => '${clock().microsecondsSinceEpoch}-${_seq++}';

  /// Sends [raw] and streams the reply into the thread.
  /// [SendResult.crisis]: the thread is already gone, show the crisis screen.
  /// [SendResult.failed]: the words were not kept; put them back to retry.
  Future<SendResult> send(String raw) async {
    final String text = raw.trim();
    if (text.isEmpty || _busy || full) return SendResult.ignored;
    // On the phone, before any service sees the words.
    if (isCrisis(text)) {
      await clear();
      return SendResult.crisis;
    }
    final EkantLang lang = detectLang(text);
    _messages.add(
      ChatMessage(
        id: _id(),
        role: ChatRole.user,
        text: text,
        at: clock(),
        lang: lang,
      ),
    );
    _busy = true;
    _waiting = true;
    notifyListeners();

    final StringBuffer buf = StringBuffer();
    final String replyId = _id();
    final DateTime at = clock();
    String? verseId;
    bool crisis = false;
    try {
      await for (final ChatChunk chunk in service.send(
        List<ChatMessage>.unmodifiable(_messages),
      )) {
        if (_disposed) return SendResult.ignored;
        switch (chunk) {
          case ChatDelta():
            buf.write(chunk.text);
            _waiting = false;
            _pending = ChatMessage(
              id: replyId,
              role: ChatRole.ekant,
              text: buf.toString(),
              at: at,
              lang: lang,
            );
            notifyListeners();
          case ChatVerse():
            verseId = chunk.verseId;
          case ChatCrisis():
            crisis = true;
        }
        if (crisis) break;
      }
    } catch (e) {
      debugPrint('EkantChat.send: $e');
      buf.clear();
    }
    if (_disposed) return SendResult.ignored;
    _pending = null;
    _waiting = false;
    _busy = false;
    if (crisis) {
      await clear();
      return SendResult.crisis;
    }
    final String reply = buf.toString().trim();
    if (reply.isEmpty) {
      _messages.removeLast();
      notifyListeners();
      return SendResult.failed;
    }
    _messages.add(
      ChatMessage(
        id: replyId,
        role: ChatRole.ekant,
        text: reply,
        at: at,
        lang: lang,
        verseId: _checked(verseId, text).id,
      ),
    );
    notifyListeners();
    await _save();
    return SendResult.sent;
  }

  /// A line said aloud in the talk room joins the thread, so switching to
  /// chat carries on from it.
  Future<void> addSpoken(ChatRole role, String text, {String? verseId}) async {
    final String t = text.trim();
    if (t.isEmpty) return;
    String? checked;
    if (role == ChatRole.ekant) {
      final String lastUser = _messages.reversed
          .firstWhere(
            (ChatMessage m) => m.role == ChatRole.user,
            orElse: () =>
                ChatMessage(id: '', role: ChatRole.user, text: '', at: clock()),
          )
          .text;
      checked = _checked(verseId, lastUser).id;
    }
    _messages.add(
      ChatMessage(
        id: _id(),
        role: role,
        text: t,
        at: clock(),
        lang: detectLang(t),
        verseId: checked,
      ),
    );
    notifyListeners();
    await _save();
  }

  /// A service only names a verse. It must exist here and be allowed as
  /// advice; otherwise the local matcher chooses. This holds for Gemini too.
  Verse _checked(String? id, String userText) {
    final Verse? v = id == null ? null : matcher.byId(id);
    if (v != null && v.adviceSafe) return v;
    return matcher.pick(tagText(userText));
  }

  Future<void> _save() async {
    try {
      await store.save(_messages);
    } catch (e) {
      debugPrint('EkantChat.save: $e');
    }
  }

  /// The thread as sitting turns, for the close (verse to carry, fade, keep).
  List<SittingTurn> turns() {
    final List<SittingTurn> out = <SittingTurn>[];
    for (int i = 0; i < _messages.length; i++) {
      final ChatMessage m = _messages[i];
      if (m.role != ChatRole.user) continue;
      ChatMessage? reply;
      for (int j = i + 1; j < _messages.length; j++) {
        if (_messages[j].role == ChatRole.user) break;
        if (_messages[j].role == ChatRole.ekant) reply = _messages[j];
      }
      final Verse verse = reply?.verseId == null
          ? matcher.pick(tagText(m.text))
          : matcher.byId(reply!.verseId!) ?? matcher.pick(tagText(m.text));
      final List<String> parts = (reply?.text ?? '').split('\n\n');
      out.add(
        SittingTurn(
          words: m.text,
          reflection: parts.first,
          verse: verse,
          lang: m.lang,
          question: parts.length > 1 ? parts.sublist(1).join('\n\n') : null,
        ),
      );
    }
    return out;
  }

  /// Lets the thread fade: nothing of it stays on the phone.
  Future<void> clear() async {
    _messages.clear();
    _pending = null;
    _busy = false;
    _waiting = false;
    try {
      await store.clear();
    } catch (e) {
      debugPrint('EkantChat.clear: $e');
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
