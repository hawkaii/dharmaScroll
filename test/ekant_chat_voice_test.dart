import 'dart:async';
import 'dart:io';

import 'package:dharmascroll/app.dart';
import 'package:dharmascroll/app_providers.dart';
import 'package:dharmascroll/core/rituals/providers.dart';
import 'package:dharmascroll/core/rituals/reminder_backend.dart';
import 'package:dharmascroll/data/verse_repository.dart';
import 'package:dharmascroll/domain/models/verse.dart';
import 'package:dharmascroll/features/ekant/chat_history.dart';
import 'package:dharmascroll/features/ekant/chat_service.dart';
import 'package:dharmascroll/features/ekant/crisis_screen.dart';
import 'package:dharmascroll/features/ekant/ekant_chat.dart';
import 'package:dharmascroll/features/ekant/ekant_engine.dart';
import 'package:dharmascroll/features/ekant/ekant_lamp.dart';
import 'package:dharmascroll/features/ekant/ekant_providers.dart';
import 'package:dharmascroll/features/ekant/ekant_screen.dart';
import 'package:dharmascroll/features/ekant/ekant_share.dart';
import 'package:dharmascroll/features/ekant/ekant_strings.dart';
import 'package:dharmascroll/features/ekant/ekant_talk.dart'
    show kMicExplainedKey;
import 'package:dharmascroll/features/ekant/ekant_voice.dart';
import 'package:dharmascroll/features/ekant/kept_notes.dart';
import 'package:dharmascroll/features/ekant/mic_access.dart';
import 'package:dharmascroll/features/ekant/voice_session.dart';
import 'package:dharmascroll/features/explain/explain_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A chat service the test drives by hand.
class _ScriptedChat implements ChatService {
  final List<List<ChatMessage>> seen = <List<ChatMessage>>[];
  StreamController<ChatChunk> out = StreamController<ChatChunk>();

  @override
  Stream<ChatChunk> send(List<ChatMessage> messages) {
    seen.add(messages);
    out = StreamController<ChatChunk>();
    return out.stream;
  }
}

/// A voice session the test drives by hand.
class _StubSession implements VoiceSession {
  final StreamController<VoiceState> st =
      StreamController<VoiceState>.broadcast();
  final StreamController<double> mic = StreamController<double>.broadcast();
  final StreamController<double> out = StreamController<double>.broadcast();
  final StreamController<Caption> caps = StreamController<Caption>.broadcast();
  VoiceState now = VoiceState.disconnected;
  bool muted = false;
  bool? handsFree;
  bool connected = false;

  void go(VoiceState s) {
    now = s;
    st.add(s);
  }

  @override
  VoiceState get current => now;
  @override
  Stream<VoiceState> get state => st.stream;
  @override
  Stream<double> get micLevel => mic.stream;
  @override
  Stream<double> get outLevel => out.stream;
  @override
  Stream<Caption> get captions => caps.stream;
  @override
  Future<void> connect() async {
    connected = true;
    go(VoiceState.idle);
  }

  @override
  Future<void> disconnect() async => connected = false;
  @override
  Future<void> setMuted(bool m) async => muted = m;
  @override
  Future<void> setHandsFree(bool h) async => handsFree = h;
  @override
  Future<void> holdToTalk(bool held) async {}
}

List<Verse> _verses() =>
    parseVerses(File('assets/data/gita_v1.json').readAsStringSync());

Future<void> _openEkant(
  WidgetTester tester, {
  List<Override> overrides = const <Override>[],
  MemoryChatHistoryStore? history,
  FakeMicAccess? mic,
  Map<String, Object> prefsValues = const <String, Object>{},
}) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(<String, Object>{
    'onboardingComplete': true,
    ...prefsValues,
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        sharedPrefsProvider.overrideWithValue(prefs),
        versesProvider.overrideWithValue(_verses()),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 12, 20)),
        reminderBackendProvider.overrideWithValue(const NoopReminderBackend()),
        keptNotesStoreProvider.overrideWithValue(MemoryKeptNotesStore()),
        ekantVoiceProvider.overrideWithValue(null),
        chatHistoryStoreProvider.overrideWithValue(
          history ?? MemoryChatHistoryStore(),
        ),
        micAccessProvider.overrideWithValue(mic ?? FakeMicAccess()),
        ...overrides,
      ],
      child: const DharmaScrollApp(),
    ),
  );
  await tester.pumpAndSettle();
  final Finder link = find.text('Ekant, a quiet room');
  await tester.ensureVisible(link);
  await tester.tap(link);
  await tester.pumpAndSettle();
}

Future<void> _write(WidgetTester tester) async {
  await tester.tap(find.text(EkantStrings.writeLabel));
  await tester.pumpAndSettle();
}

/// Takes the room down and lets the drone fade, so no timer is left over.
Future<void> _leave(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  group('EkantChat (controller)', () {
    late _ScriptedChat service;
    late MemoryChatHistoryStore store;
    late EkantChat chat;

    setUp(() {
      service = _ScriptedChat();
      store = MemoryChatHistoryStore();
      chat = EkantChat(
        service: service,
        store: store,
        matcher: VerseMatcher(_verses()),
        clock: () => DateTime(2026, 11, 12, 20),
      );
    });
    tearDown(() => chat.dispose());

    test('streams text, then keeps the thread on the phone', () async {
      final Future<SendResult> sent = chat.send('Work is heavy');
      await Future<void>.delayed(Duration.zero);
      expect(chat.waiting, isTrue, reason: 'no word yet: the lamp flickers');
      expect(chat.messages.single.role, ChatRole.user);

      service.out.add(const ChatDelta('You carry '));
      await Future<void>.delayed(Duration.zero);
      expect(chat.waiting, isFalse);
      expect(chat.streaming, isTrue);
      expect(chat.messages.last.text, 'You carry ');

      service.out
        ..add(const ChatDelta('a lot.'))
        ..add(const ChatVerse('2.47'));
      await service.out.close();
      expect(await sent, SendResult.sent);

      expect(chat.streaming, isFalse);
      expect(chat.messages.last.text, 'You carry a lot.');
      expect(chat.messages.last.verseId, '2.47');
      expect(store.messages, hasLength(2), reason: 'saved on the phone');
    });

    test(
      'a verse the app cannot offer is replaced from local verses',
      () async {
        final Future<SendResult> sent = chat.send('I am so anxious');
        await Future<void>.delayed(Duration.zero);
        service.out
          ..add(const ChatDelta('Worry runs ahead.'))
          ..add(const ChatVerse('99.99'));
        await service.out.close();
        await sent;
        final String id = chat.messages.last.verseId!;
        expect(id, isNot('99.99'));
        expect(VerseMatcher(_verses()).byId(id)?.adviceSafe, isTrue);
      },
    );

    test('crisis words never reach the service and wipe the thread', () async {
      final Future<SendResult> first = chat.send('hello');
      await Future<void>.delayed(Duration.zero);
      service.out.add(const ChatDelta('Hello.'));
      await service.out.close();
      await first;
      expect(service.seen, hasLength(1));
      final SendResult r = await chat.send('I want to kill myself');
      expect(r, SendResult.crisis);
      expect(service.seen, hasLength(1), reason: 'not sent anywhere');
      expect(chat.messages, isEmpty);
      expect(store.messages, isEmpty);
    });

    test('a service that fails gives the words back', () async {
      final Future<SendResult> sent = chat.send('Work is heavy');
      await Future<void>.delayed(Duration.zero);
      service.out.addError(StateError('offline'));
      await service.out.close().catchError((_) {});
      expect(await sent, SendResult.failed);
      expect(chat.messages, isEmpty);
      expect(chat.busy, isFalse);
    });

    test('the fake service answers from the verses, word by word', () async {
      final FakeChatService fake = FakeChatService(
        TemplateResponder(VerseMatcher(_verses())),
        thinkDelay: Duration.zero,
        wordDelay: Duration.zero,
      );
      final List<ChatChunk> chunks = await fake.send(<ChatMessage>[
        ChatMessage(
          id: '1',
          role: ChatRole.user,
          text: 'Work is heavy',
          at: DateTime(2026),
        ),
      ]).toList();
      expect(chunks.whereType<ChatDelta>().length, greaterThan(3));
      expect(chunks.last, isA<ChatVerse>());
    });
  });

  group('chat room', () {
    testWidgets('the lamp flickers, the reply streams, the verse card opens '
        'the study sheet', (WidgetTester tester) async {
      final _ScriptedChat service = _ScriptedChat();
      final MemoryChatHistoryStore history = MemoryChatHistoryStore();
      await _openEkant(
        tester,
        history: history,
        overrides: <Override>[chatServiceProvider.overrideWithValue(service)],
      );
      await _write(tester);
      expect(find.text(EkantScreen.prompt), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Work is heavy');
      await tester.pump();
      await tester.tap(find.text(EkantStrings.sendLabel));
      await tester.pump();
      expect(find.text('Work is heavy'), findsOneWidget);
      expect(find.byType(LampFlicker), findsOneWidget);

      service.out.add(const ChatDelta('You carry '));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(LampFlicker), findsNothing);
      expect(find.textContaining('You carry'), findsOneWidget);
      expect(find.textContaining('GITA'), findsNothing, reason: 'not yet');

      service.out
        ..add(const ChatDelta('a lot.'))
        ..add(const ChatVerse('2.47'));
      await service.out.close();
      await tester.pumpAndSettle();
      expect(find.text('You carry a lot.'), findsOneWidget);
      expect(find.text('GITA 2.47'), findsOneWidget);
      expect(find.text(EkantStrings.copyLabel), findsOneWidget);
      expect(find.text(EkantStrings.shareLabel), findsOneWidget);

      await tester.tap(find.text('GITA 2.47'));
      await tester.pumpAndSettle();
      expect(find.byType(ExplainSheet), findsOneWidget);
      await tester.tapAt(const Offset(195, 20)); // the dimmed edge closes it
      await tester.pumpAndSettle();
      expect(find.byType(ExplainSheet), findsNothing);
      await _leave(tester);
    });

    testWidgets('Copy and Share work on a reply; the user words stay out', (
      WidgetTester tester,
    ) async {
      final _ScriptedChat service = _ScriptedChat();
      await _openEkant(
        tester,
        overrides: <Override>[chatServiceProvider.overrideWithValue(service)],
      );
      String? clip;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            clip = (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      String? shared;
      final Future<void> Function(String) old = EkantShare.send;
      EkantShare.send = (String t) async => shared = t;
      addTearDown(() => EkantShare.send = old);

      await _write(tester);
      await tester.enterText(find.byType(TextField), 'my private words');
      await tester.pump();
      await tester.tap(find.text(EkantStrings.sendLabel));
      await tester.pump();
      service.out
        ..add(const ChatDelta('You carry a lot.'))
        ..add(const ChatVerse('2.47'));
      await service.out.close();
      await tester.pumpAndSettle();

      await tester.tap(find.text(EkantStrings.copyLabel));
      await tester.pump();
      expect(clip, contains('You carry a lot.'));
      expect(clip, contains('Gita 2.47'));
      expect(clip, isNot(contains('my private words')));
      expect(find.text(EkantStrings.copiedLabel), findsOneWidget);

      await tester.tap(find.text(EkantStrings.shareLabel));
      await tester.pump();
      expect(shared, contains('You carry a lot.'));
      expect(shared, isNot(contains('my private words')));
      await tester.pump(const Duration(seconds: 3)); // "Copied" resets
      await _leave(tester);
    });

    testWidgets('opening lines are quiet prompts that fill the box', (
      WidgetTester tester,
    ) async {
      await _openEkant(tester);
      await _write(tester);
      for (final String line in EkantStrings.openingLines) {
        expect(find.text(line), findsOneWidget);
      }
      expect(find.byType(ChoiceChip), findsNothing);
      expect(find.byType(ActionChip), findsNothing);
      await tester.tap(find.text(EkantStrings.openingLines.first));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        EkantStrings.openingLines.first,
      );
      expect(find.text('Rest now'), findsNothing, reason: 'nothing sent yet');
      await _leave(tester);
    });

    testWidgets('the thread comes back after leaving the room', (
      WidgetTester tester,
    ) async {
      final MemoryChatHistoryStore history = MemoryChatHistoryStore();
      history.messages = <ChatMessage>[
        ChatMessage(
          id: 'a',
          role: ChatRole.user,
          text: 'Yesterday was hard',
          at: DateTime(2026, 11, 11),
        ),
        ChatMessage(
          id: 'b',
          role: ChatRole.ekant,
          text: 'It was.',
          at: DateTime(2026, 11, 11),
          verseId: '2.47',
        ),
      ];
      await _openEkant(tester, history: history);
      expect(find.textContaining(EkantStrings.doorWaiting), findsOneWidget);
      await _write(tester);
      expect(find.text('Yesterday was hard'), findsOneWidget);
      expect(find.text('It was.'), findsOneWidget);
      expect(find.text('GITA 2.47'), findsOneWidget);
      await _leave(tester);
    });
  });

  group('FakeVoiceSession (timers)', () {
    testWidgets('moves through connect, listen, think, speak and back', (
      WidgetTester tester,
    ) async {
      final FakeVoiceSession s = FakeVoiceSession(
        responder: TemplateResponder(VerseMatcher(_verses())),
      );
      final List<VoiceState> seen = <VoiceState>[];
      final List<Caption> caps = <Caption>[];
      final List<double> mic = <double>[];
      final List<double> out = <double>[];
      s.state.listen(seen.add);
      s.captions.listen(caps.add);
      s.micLevel.listen(mic.add);
      s.outLevel.listen(out.add);

      expect(s.current, VoiceState.disconnected);
      await s.connect();
      await tester.pump(const Duration(seconds: 12));
      expect(seen.take(5), <VoiceState>[
        VoiceState.connecting,
        VoiceState.idle,
        VoiceState.listening,
        VoiceState.thinking,
        VoiceState.speaking,
      ]);
      expect(mic.any((double v) => v > 0.2), isTrue, reason: 'mic level moves');
      expect(out.any((double v) => v > 0.2), isTrue, reason: 'output moves');

      final Caption said = caps.firstWhere(
        (Caption c) => c.speaker == CaptionSpeaker.user && c.isFinal,
      );
      expect(said.text, FakeVoiceSession.script.first);
      final Caption reply = caps.firstWhere(
        (Caption c) => c.speaker == CaptionSpeaker.ekant && c.isFinal,
      );
      expect(reply.text, isNotEmpty);
      expect(
        VerseMatcher(_verses()).byId(reply.verseId!),
        isNotNull,
        reason: 'the reply names a real verse',
      );
      // Partial captions grow under one id.
      final Iterable<Caption> partial = caps.where(
        (Caption c) => c.id == said.id && !c.isFinal,
      );
      expect(partial.length, greaterThan(2));
      expect(partial.last.text.length, greaterThan(partial.first.text.length));

      await s.disconnect();
      expect(s.current, VoiceState.disconnected);
    });

    testWidgets('mute holds the session back; push-to-talk waits for a hold', (
      WidgetTester tester,
    ) async {
      final FakeVoiceSession s = FakeVoiceSession(
        responder: TemplateResponder(VerseMatcher(_verses())),
      );
      await s.setMuted(true);
      await s.connect();
      await tester.pump(const Duration(seconds: 3));
      expect(s.current, VoiceState.idle, reason: 'muted: never listens');
      await s.setMuted(false);
      await s.setHandsFree(false);
      await tester.pump(const Duration(seconds: 3));
      expect(s.current, VoiceState.idle, reason: 'push-to-talk: waits');
      await s.holdToTalk(true);
      await tester.pump(const Duration(seconds: 1));
      expect(s.current, VoiceState.listening);
      await s.holdToTalk(false);
      await tester.pump(const Duration(milliseconds: 100));
      expect(s.current, VoiceState.thinking);
      await s.disconnect();
    });
  });

  group('talk room', () {
    testWidgets('explainer first, then the lamp follows the conversation', (
      WidgetTester tester,
    ) async {
      final FakeMicAccess mic = FakeMicAccess();
      final MemoryChatHistoryStore history = MemoryChatHistoryStore();
      await _openEkant(tester, history: history, mic: mic);
      await tester.tap(find.text(EkantStrings.speakLabel));
      await tester.pumpAndSettle();
      expect(find.text(EkantStrings.micTitle), findsOneWidget);
      expect(mic.asked, 0, reason: 'explained before it asks');

      await tester.tap(find.text(EkantStrings.micAllow));
      await tester.pump();
      await tester.pump();
      expect(mic.asked, 1);
      expect(find.text('GETTING READY'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('LISTENING'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.textContaining('Work has been'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('THINKING'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1800));
      expect(find.text('SPEAKING'), findsOneWidget);

      // Large, labelled controls.
      for (final String label in <String>[
        EkantStrings.muteLabel,
        EkantStrings.endLabel,
        EkantStrings.chatLabel,
      ]) {
        final Finder f = find.text(label);
        expect(f, findsOneWidget);
        final Size box = tester.getSize(
          find.ancestor(of: f, matching: find.byType(Column)).first,
        );
        expect(box.width, greaterThanOrEqualTo(56));
      }
      await tester.tap(find.text(EkantStrings.muteLabel));
      await tester.pump();
      expect(find.text(EkantStrings.unmuteLabel), findsOneWidget);

      // Run to the end of the reply, then carry on in writing.
      await tester.pump(const Duration(seconds: 8));
      await tester.tap(find.text(EkantStrings.chatLabel));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text(FakeVoiceSession.script.first), findsOneWidget);
      expect(history.messages.map((ChatMessage m) => m.role), <ChatRole>[
        ChatRole.user,
        ChatRole.ekant,
      ]);
      await _leave(tester);
    });

    testWidgets('"Not now" on the explainer goes to writing', (
      WidgetTester tester,
    ) async {
      final FakeMicAccess mic = FakeMicAccess();
      await _openEkant(tester, mic: mic);
      await tester.tap(find.text(EkantStrings.speakLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(EkantStrings.micNotNow));
      await tester.pumpAndSettle();
      expect(mic.asked, 0);
      expect(find.byType(TextField), findsOneWidget);
      await _leave(tester);
    });

    testWidgets('a refused microphone is said plainly', (
      WidgetTester tester,
    ) async {
      await _openEkant(
        tester,
        mic: FakeMicAccess(allow: false),
        prefsValues: <String, Object>{kMicExplainedKey: true},
      );
      await tester.tap(find.text(EkantStrings.speakLabel));
      await tester.pumpAndSettle();
      expect(find.text(EkantStrings.micTitle), findsNothing, reason: 'seen');
      expect(find.text(EkantStrings.micDenied), findsOneWidget);
      await tester.tap(find.text(EkantStrings.endLabel));
      await tester.pumpAndSettle();
      expect(find.text(EkantStrings.writeLabel), findsOneWidget);
      await _leave(tester);
    });

    testWidgets('push to talk shows a hold button', (
      WidgetTester tester,
    ) async {
      await _openEkant(
        tester,
        prefsValues: <String, Object>{kMicExplainedKey: true},
      );
      await tester.tap(find.text(EkantStrings.speakLabel));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text(EkantStrings.pushLabel));
      await tester.pump();
      expect(find.text(EkantStrings.holdLabel), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('READY'), findsOneWidget, reason: 'waits for a hold');
      final TestGesture g = await tester.startGesture(
        tester.getCenter(find.text(EkantStrings.holdLabel)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('LISTENING'), findsOneWidget);
      expect(find.text(EkantStrings.releaseLabel), findsOneWidget);
      await g.up();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('THINKING'), findsOneWidget);
      await tester.tap(find.text(EkantStrings.endLabel));
      await tester.pumpAndSettle();
      await _leave(tester);
    });
  });

  group('seams', () {
    testWidgets(
      'a swapped VoiceSession drives the room, crisis words stop it',
      (WidgetTester tester) async {
        final _StubSession session = _StubSession();
        await _openEkant(
          tester,
          overrides: <Override>[
            voiceSessionFactoryProvider.overrideWithValue(() => session),
          ],
          prefsValues: <String, Object>{kMicExplainedKey: true},
        );
        await tester.tap(find.text(EkantStrings.speakLabel));
        await tester.pump();
        await tester.pump();
        expect(session.connected, isTrue);
        expect(session.handsFree, isTrue);

        session.go(VoiceState.speaking);
        session.out.add(0.8);
        session.caps.add(
          const Caption(
            id: 1,
            speaker: CaptionSpeaker.ekant,
            text: 'From the stub',
            isFinal: true,
            verseId: '2.47',
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('SPEAKING'), findsOneWidget);
        expect(find.text('From the stub'), findsOneWidget);
        expect(find.textContaining('GITA 2.47'), findsOneWidget);

        await tester.tap(find.text(EkantStrings.muteLabel));
        await tester.pump();
        expect(session.muted, isTrue);

        session.caps.add(
          const Caption(
            id: 2,
            speaker: CaptionSpeaker.user,
            text: 'I want to kill myself',
            isFinal: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CrisisScreen), findsOneWidget);
        expect(find.textContaining('kill myself'), findsNothing);
        expect(session.connected, isFalse, reason: 'the call ended');
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        await _leave(tester);
      },
    );

    test('the Gemini and LiveKit stubs are not hooked up yet', () async {
      expect(
        () => const GeminiChatService().send(const <ChatMessage>[]),
        throwsUnimplementedError,
      );
      final LiveKitVoiceSession lk = LiveKitVoiceSession(
        tokenProvider: () async => 'token',
      );
      await expectLater(lk.connect(), throwsUnimplementedError);
      expect(lk.current, VoiceState.disconnected);
    });

    test('the default providers are the fakes', () {
      final ProviderContainer c = ProviderContainer(
        overrides: <Override>[versesProvider.overrideWithValue(_verses())],
      );
      addTearDown(c.dispose);
      expect(c.read(chatServiceProvider), isA<FakeChatService>());
      expect(c.read(voiceSessionFactoryProvider)(), isA<FakeVoiceSession>());
    });
  });
}
