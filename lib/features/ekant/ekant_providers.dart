import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import 'chat_service.dart';
import 'ekant_engine.dart';
import 'voice_session.dart';

final Provider<VerseMatcher> ekantMatcherProvider = Provider<VerseMatcher>(
  (Ref ref) => VerseMatcher(ref.watch(versesProvider)),
);

/// The on-phone responder (keyword tags, fixed templates). The fake chat and
/// voice services below use it, so every reply is grounded in a real verse.
final Provider<EkantResponder> ekantResponderProvider =
    Provider<EkantResponder>(
      (Ref ref) => TemplateResponder(ref.watch(ekantMatcherProvider)),
    );

/// SWAP POINT 1: written replies.
/// To use Gemini, return `GeminiChatService()` (see `chat_service.dart`).
final Provider<ChatService> chatServiceProvider = Provider<ChatService>(
  (Ref ref) => FakeChatService(ref.watch(ekantResponderProvider)),
);

/// SWAP POINT 2: talking. A new session is made each time the talk room
/// opens. To use LiveKit, return a `LiveKitVoiceSession(...)` from the
/// factory (see `voice_session.dart`).
final Provider<VoiceSession Function()> voiceSessionFactoryProvider =
    Provider<VoiceSession Function()>((Ref ref) {
      final EkantResponder responder = ref.watch(ekantResponderProvider);
      return () => FakeVoiceSession(responder: responder);
    });
