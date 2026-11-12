import 'dart:io';

import 'package:dharmascroll/data/verse_repository.dart';
import 'package:dharmascroll/domain/models/verse.dart';
import 'package:dharmascroll/features/ekant/ekant_engine.dart';
import 'package:dharmascroll/features/ekant/ekant_lexicon.dart';
import 'package:dharmascroll/features/ekant/ekant_sitting.dart';
import 'package:dharmascroll/features/ekant/kept_notes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Twenty everyday inputs, the verse they get, and the tag that makes the
/// verse a sensible answer. The ids are pinned so a lexicon change that
/// moves a mapping is a visible diff, not a silent one.
const List<(String, String, String)> samples = <(String, String, String)>[
  (
    'Aaj review mein manager ne sabke saamne bola ki mera kaam average hai. Itni mehnat ki thi.',
    '2.47',
    'work-pressure',
  ),
  (
    'Can\u2019t sleep. Placement results on Friday. My brain keeps playing every bad outcome.',
    '2.47',
    'exam-stress',
  ),
  (
    'Agle hafte Baba ki barsi hai. Do saal ho gaye. Ghar mein sab normal hain, main nahi.',
    '18.66',
    'grief',
  ),
  (
    'I have been hiding my relationship from my parents for a year. I feel like a terrible daughter.',
    '15.7',
    'self-worth',
  ),
  ('I am so angry at my brother, I shouted at him today.', '17.15', 'anger'),
  (
    'Everyone in my batch got placed and I am still waiting. Why is everyone else better than me?',
    '4.22',
    'comparison',
  ),
  (
    'I feel so lonely in this new city, I have no friends here.',
    '10.9',
    'loneliness',
  ),
  (
    'I keep scrolling my phone all day and cannot focus on anything.',
    '6.35',
    'focus',
  ),
  ('मुझे बहुत चिंता हो रही है, कल परीक्षा है।', '2.47', 'anxiety'),
  (
    'My father passed away last month and I miss him every day.',
    '18.66',
    'grief',
  ),
  ('I failed my exam again. I feel useless.', '6.5', 'failure'),
  ('I am jealous of my best friend.', '4.22', 'envy'),
  (
    'I do not know if I should take the job abroad or stay with my parents.',
    '18.63',
    'duty-conflict',
  ),
  ('So tired of work, I am completely burnt out.', '4.18', 'burnout'),
  ('I keep putting off my studies, I am so lazy.', '18.37', 'procrastination'),
  ('Mujhe bahut gussa aata hai, chhoti chhoti baaton pe.', '16.2', 'anger'),
  (
    'I said something rude to my mother and I regret it.',
    '11.55',
    'forgiveness',
  ),
  (
    'I want more discipline in my routine and to wake up early.',
    '2.58',
    'discipline',
  ),
  ('Mera breakup ho gaya, woh mujhe chhod ke chali gayi.', '2.22', 'loss'),
  ('I feel grateful today, things are finally calm.', '6.30', 'gratitude'),
];

const List<String> crisisInputs = <String>[
  'I want to kill myself',
  'Sometimes I think about suicide',
  'I don\u2019t want to live anymore',
  'I wish I were dead',
  'I have been cutting myself again',
  'My husband beats me every night',
  'I took too many pills, maybe an overdose',
  'Mujhe mar jaana hai',
  'Ab jeena nahi chahta',
  'Sab khatam kar dunga main',
  'Neend ki goliyan kha lunga',
  'Papa roz maarte hain',
  'मैं आत्महत्या करना चाहता हूँ',
  'मुझे अब जीना नहीं है',
  'मेरे पति मुझे मारते हैं',
  'ख़ुदकुशी के बारे में सोचती हूँ',
];

void main() {
  final List<Verse> verses = parseVerses(
    File('assets/data/gita_v1.json').readAsStringSync(),
  );
  final VerseMatcher matcher = VerseMatcher(verses);
  final TemplateResponder room = TemplateResponder(matcher);
  final Set<String> excluded = <String>{
    for (final Verse v in verses)
      if (!v.adviceSafe) v.id,
  };

  test('the data has excluded verses to guard against', () {
    expect(excluded, isNotEmpty);
  });

  group('20 sample inputs', () {
    for (final (String text, String id, String tag) in samples) {
      test('"$text" -> GITA $id', () async {
        expect(isCrisis(text), isFalse);
        final EkantReply r = await room.respond(
          EkantRequest(text: text, turn: 1, maxTurns: 8),
        );
        expect(r, isA<EkantAnswer>());
        final EkantAnswer a = r as EkantAnswer;
        final Verse v = matcher.byId(a.verseId)!;
        expect(v.tags, contains(tag), reason: 'GITA ${v.id} ${v.tags}');
        expect(a.verseId, id);
        expect(v.adviceSafe, isTrue);
      });
    }
  });

  test('no excluded verse is ever returned, across whole sittings', () async {
    final List<String> inputs = <String>[
      for (final (String t, _, _) in samples) t,
      ...kTagWords.keys,
      'death',
      'mortality',
      'war',
      'fight',
      'duty',
      'caste',
      '',
    ];
    for (final String text in inputs) {
      final Set<String> shown = <String>{};
      for (int turn = 1; turn <= 40; turn++) {
        final EkantReply r = await room.respond(
          EkantRequest(text: text, turn: turn, maxTurns: 40, shown: shown),
        );
        final String id = (r as EkantAnswer).verseId;
        expect(excluded, isNot(contains(id)), reason: '"$text" turn $turn');
        shown.add(id);
      }
    }
    for (final String tag in kTagWords.keys) {
      expect(
        excluded,
        isNot(contains(matcher.pick(<String, double>{tag: 1}).id)),
      );
    }
  });

  test('death verses only for plain grief', () {
    final Verse v = matcher.pick(<String, double>{'mortality': 3, 'fear': 1});
    expect(v.tags, isNot(contains('mortality')));
    final Verse g = matcher.pick(<String, double>{'grief': 3, 'mortality': 2});
    expect(g.adviceSafe, isTrue);
  });

  test('crisis words always go to the crisis screen', () async {
    for (final String text in crisisInputs) {
      expect(isCrisis(text), isTrue, reason: text);
      expect(
        await room.respond(EkantRequest(text: text, turn: 1, maxTurns: 8)),
        isA<EkantCrisis>(),
        reason: text,
      );
      final EkantSitting s = EkantSitting(
        responder: room,
        matcher: matcher,
        clock: DateTime.now,
      )..enter();
      await s.share('Work has been hard this week.');
      expect(await s.share(text), isTrue, reason: text);
      expect(s.turns, isEmpty, reason: 'words are dropped: $text');
    }
  });

  test('everyday phrases are not crisis', () {
    for (final String t in <String>[
      'This exam is killing me',
      'It hit me that I was wrong',
      'Main toh office jaati hoon',
      'My boss shouted at me',
    ]) {
      expect(isCrisis(t), isFalse, reason: t);
    }
  });

  test('replies never speak as a person or as God', () {
    final Iterable<String> lines = <String>[
      for (final Map<EkantLang, List<String>> m in kReflections.values)
        for (final List<String> l in m.values) ...l,
      for (final List<String> l in kQuestions.values) ...l,
      for (final Map<EkantLang, String> m in kFixedLines.values) ...m.values,
    ];
    final RegExp i = RegExp(r"\b(I|me|my|mine|I'm|main|mera|meri|mujhe)\b");
    for (final String l in lines) {
      expect(i.hasMatch(l), isFalse, reason: l);
      expect(l, isNot(contains('!')));
    }
  });

  test('hard cases get the fixed line', () async {
    final EkantAnswer a = await room.respond(
      const EkantRequest(text: 'Are you Krishna?', turn: 1, maxTurns: 8),
    ) as EkantAnswer;
    expect(a.reflection, kFixedLines[HardCase.identity]![EkantLang.en]);
    final EkantAnswer m = await room.respond(
      const EkantRequest(
        text: 'Should I stop my medicine?',
        turn: 1,
        maxTurns: 8,
      ),
    ) as EkantAnswer;
    expect(m.reflection, kFixedLines[HardCase.medicine]![EkantLang.en]);
  });

  test('language follows the words', () {
    expect(detectLang('I am tired'), EkantLang.en);
    expect(detectLang('Mujhe bahut thakan hai'), EkantLang.hinglish);
    expect(detectLang('मैं थका हूँ'), EkantLang.hi);
  });

  test('a sitting stops at 8 turns and at 15 minutes', () async {
    DateTime now = DateTime(2026, 11, 12, 20);
    final EkantSitting s = EkantSitting(
      responder: room,
      matcher: matcher,
      clock: () => now,
    )..enter();
    for (int i = 0; i < 8; i++) {
      await s.share('Work is heavy today, turn $i');
    }
    expect(s.full, isTrue);
    expect(s.turns.last.question, isNull);
    await s.share('one more');
    expect(s.turns, hasLength(8));
    expect(s.turns.map((SittingTurn t) => t.verse.id).toSet(), hasLength(8));

    final EkantSitting t = EkantSitting(
      responder: room,
      matcher: matcher,
      clock: () => now,
    )..enter();
    await t.share('I am anxious');
    now = now.add(EkantSitting.maxLength);
    expect(t.full, isTrue);
  });

  test('keep stores the words on the phone; let go drops them', () async {
    final MemoryKeptNotesStore store = MemoryKeptNotesStore();
    final EkantSitting s = EkantSitting(
      responder: room,
      matcher: matcher,
      clock: DateTime.now,
    )..enter();
    await s.share('I am so angry today');
    final String carry = s.turns.last.verse.id;
    s.rest();
    await s.keep(store);
    expect(store.notes.single.words, <String>['I am so angry today']);
    expect(store.notes.single.verseId, carry);
    expect(s.turns, isEmpty);
    expect(s.carry.id, carry);
  });
}
