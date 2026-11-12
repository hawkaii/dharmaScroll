import '../../domain/models/verse.dart';
import 'ekant_lexicon.dart';

/// The language of one turn, read from the user's own words.
enum EkantLang { en, hinglish, hi }

/// Lower case, apostrophes and nukta removed, every other mark turned into a
/// space, padded with one space on each side so `' $entry'` is a word start.
String normalise(String raw) {
  final String s = raw
      .toLowerCase()
      .replaceAll('\u093C', '') // nukta: ख़ुद and खुद are one word here
      .replaceAll(RegExp('[\u200C\u200D\'\u2019`]'), '')
      .replaceAll(RegExp(r'[^a-z0-9\u0900-\u0963\u0966-\u097F]+'), ' ')
      .trim();
  return ' $s ';
}

bool _has(String norm, String entry) => norm.contains(' $entry');

/// Runs on the phone before anything else sees the words.
bool isCrisis(String text) {
  final String n = normalise(text);
  return kCrisisPhrases.any((String p) => _has(n, p));
}

EkantLang detectLang(String text) {
  if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) return EkantLang.hi;
  final Iterable<String> words = normalise(text).trim().split(' ');
  final int hits = words.where(kHinglishMarkers.contains).length;
  return hits >= 2 ? EkantLang.hinglish : EkantLang.en;
}

/// Order matters: harm to others and medicine before anything softer.
const List<HardCase> _hardCaseOrder = <HardCase>[
  HardCase.harmOthers,
  HardCase.identity,
  HardCase.medicine,
  HardCase.lawMoney,
  HardCase.astrology,
  HardCase.future,
  HardCase.blessing,
  HardCase.caste,
  HardCase.politics,
  HardCase.religion,
  HardCase.affection,
  HardCase.decision,
];

HardCase? detectHardCase(String text) {
  final String n = normalise(text);
  for (final HardCase h in _hardCaseOrder) {
    if (kHardCaseWords[h]!.any((String w) => _has(n, w))) return h;
  }
  return null;
}

/// Tag -> how many of its words appear in [text].
Map<String, double> tagText(String text) {
  final String n = normalise(text);
  final Map<String, double> out = <String, double>{};
  kTagWords.forEach((String tag, List<String> words) {
    final int hits = words.where((String w) => _has(n, w)).length;
    if (hits > 0) out[tag] = hits.toDouble();
  });
  return out;
}

/// Finds verses for a set of tag scores. Only verses that may be offered as
/// personal guidance are ever returned.
class VerseMatcher {
  VerseMatcher(List<Verse> verses)
    : _verses = verses,
      _byId = <String, Verse>{for (final Verse v in verses) v.id: v};

  final List<Verse> _verses;
  final Map<String, Verse> _byId;

  /// Shown when nothing in the words matches a tag.
  static const Map<String, double> calm = <String, double>{
    'peace': 1,
    'equanimity': 0.9,
    'patience': 0.8,
  };

  Verse? byId(String id) => _byId[id];

  static String? topTag(Map<String, double> scores) {
    String? best;
    scores.forEach((String t, double s) {
      if (best == null || s > scores[best]!) best = t;
    });
    return best;
  }

  /// False for verses flagged unsafe as advice. Verses on death and the
  /// undying self are kept for plain grief only (PRODUCT_DESIGN 5.6).
  bool allowed(Verse v, {String? top}) =>
      v.adviceSafe &&
      (!v.tags.contains('mortality') || top == 'grief' || top == 'loss');

  Verse pick(Map<String, double> scores, {Set<String> avoid = const {}}) {
    final Map<String, double> s = scores.isEmpty ? calm : scores;
    final String? top = topTag(s);
    Verse? best;
    double bestScore = 0;
    for (final Verse v in _verses) {
      if (avoid.contains(v.id) || !allowed(v, top: top)) continue;
      double score = 0;
      for (int i = 0; i < v.tags.length; i++) {
        score += (s[v.tags[i]] ?? 0) * (1 - 0.12 * i);
      }
      // Strictly greater: on a tie the better-loved (earlier) verse wins.
      if (score > bestScore) {
        best = v;
        bestScore = score;
      }
    }
    if (best != null) return best;
    if (!identical(s, calm)) return pick(calm, avoid: avoid);
    // Every calm verse already shown this sitting: allow a repeat.
    return pick(calm);
  }
}

/// What the room is given for one turn. Shaped so a model-backed responder
/// can take the same input (PRODUCT_DESIGN 5.6: this turn plus the last two).
class EkantRequest {
  const EkantRequest({
    required this.text,
    required this.turn,
    required this.maxTurns,
    this.earlier = const <String>[],
    this.shown = const <String>{},
  });

  final String text;

  /// 1-based.
  final int turn;
  final int maxTurns;

  /// Up to two earlier turns, oldest first.
  final List<String> earlier;

  /// Verse ids already offered this sitting.
  final Set<String> shown;

  bool get last => turn >= maxTurns;
}

sealed class EkantReply {
  const EkantReply();
}

/// Go to the crisis screen. No verse, no words, no points.
final class EkantCrisis extends EkantReply {
  const EkantCrisis();
}

/// One reflection, one verse id, at most one question. The verse itself is
/// always rendered from the local database by its id.
final class EkantAnswer extends EkantReply {
  const EkantAnswer({
    required this.reflection,
    required this.verseId,
    required this.lang,
    this.question,
  });

  final String reflection;
  final String verseId;
  final EkantLang lang;
  final String? question;
}

/// The seam for a later model-backed room. The UI only talks to this.
abstract interface class EkantResponder {
  Future<EkantReply> respond(EkantRequest request);
}

/// On-phone room: keyword tags, fixed templates, no model.
class TemplateResponder implements EkantResponder {
  TemplateResponder(this.matcher);

  final VerseMatcher matcher;

  @override
  Future<EkantReply> respond(EkantRequest r) async {
    if (isCrisis(r.text)) return const EkantCrisis();
    final EkantLang lang = detectLang(r.text);
    final int i = r.turn - 1;

    // This turn counts in full, the one before half, the one before that a
    // quarter: a short answer ("both, honestly") keeps the earlier theme.
    final Map<String, double> scores = tagText(r.text);
    double w = 0.5;
    for (final String e in r.earlier.reversed) {
      tagText(e).forEach((String t, double s) {
        scores[t] = (scores[t] ?? 0) + s * w;
      });
      w /= 2;
    }

    final HardCase? hard = detectHardCase(r.text);
    Verse? verse;
    if (hard != null) {
      final String? id = kHardCaseVerse[hard];
      final Verse? v = id == null ? null : matcher.byId(id);
      if (v != null && matcher.allowed(v) && !r.shown.contains(v.id)) {
        verse = v;
      }
    }
    verse ??= matcher.pick(scores, avoid: r.shown);

    final String reflection = hard != null
        ? kFixedLines[hard]![lang]!
        : _rotate(
            kReflections[_moodOf(VerseMatcher.topTag(scores))]![lang]!,
            i,
          );
    return EkantAnswer(
      reflection: reflection,
      verseId: verse.id,
      lang: lang,
      question: r.last ? null : _rotate(kQuestions[lang]!, i),
    );
  }

  static String _rotate(List<String> list, int i) => list[i % list.length];
}

enum Mood {
  work,
  worry,
  anger,
  grief,
  alone,
  unsure,
  worth,
  want,
  words,
  other,
}

Mood _moodOf(String? tag) => switch (tag) {
  'work-pressure' ||
  'exam-stress' ||
  'perfectionism' ||
  'burnout' ||
  'failure' ||
  'procrastination' => Mood.work,
  'anxiety' || 'fear' || 'restlessness' => Mood.worry,
  'anger' || 'envy' || 'comparison' || 'pride' || 'greed' => Mood.anger,
  'grief' || 'loss' || 'mortality' || 'change' => Mood.grief,
  'loneliness' => Mood.alone,
  'doubt' || 'confusion' || 'duty-conflict' => Mood.unsure,
  'self-doubt' || 'self-worth' => Mood.worth,
  'desire' || 'habits' || 'discipline' || 'focus' => Mood.want,
  'speech' || 'forgiveness' || 'kindness' || 'compassion' => Mood.words,
  _ => Mood.other,
};

/// The verse a hard case points to, when one fits; otherwise the tags pick.
const Map<HardCase, String> kHardCaseVerse = <HardCase, String>{
  HardCase.harmOthers: '2.63',
  HardCase.identity: '2.70',
  HardCase.blessing: '9.26',
  HardCase.future: '2.47',
  HardCase.astrology: '2.47',
  HardCase.medicine: '6.17',
  HardCase.caste: '6.32',
};

/// Reviewed fixed lines (PRODUCT_DESIGN 5.8). Never generated.
const Map<HardCase, Map<EkantLang, String>>
kFixedLines = <HardCase, Map<EkantLang, String>>{
  HardCase.identity: <EkantLang, String>{
    EkantLang.en: 'No. This is a quiet room in an app. Software finds verses. Only the verses are the Gita\u2019s words.',
    EkantLang.hinglish: 'Nahi. Yeh app ka ek shaant kamra hai. Software shlok dhoondhta hai. Sirf shlok Gita ke shabd hain.',
    EkantLang.hi: 'नहीं। यह ऐप का एक शांत कमरा है। सॉफ़्टवेयर श्लोक ढूँढता है। सिर्फ़ श्लोक गीता के शब्द हैं।',
  },
  HardCase.blessing: <EkantLang, String>{
    EkantLang.en:
        'This room cannot pray or bless. Here is a verse you can hold.',
    EkantLang.hinglish: 'Yeh kamra prarthana ya aashirwad nahi de sakta. Yeh shlok aap saath rakh sakte hain.',
    EkantLang.hi: 'यह कमरा प्रार्थना या आशीर्वाद नहीं दे सकता। यह श्लोक आप साथ रख सकते हैं।',
  },
  HardCase.future: <EkantLang, String>{
    EkantLang.en:
        'The Gita does not tell the future. It speaks about how to act now.',
    EkantLang.hinglish:
        'Gita bhavishya nahi batati. Woh batati hai ki abhi kaise karm karein.',
    EkantLang.hi: 'गीता भविष्य नहीं बताती। वह बताती है कि अभी कैसे कर्म करें।',
  },
  HardCase.astrology: <EkantLang, String>{
    EkantLang.en:
        'This room does not do astrology, remedies or mantras for results.',
    EkantLang.hinglish: 'Yeh kamra jyotish, upay ya phal ke mantra nahi deta.',
    EkantLang.hi: 'यह कमरा ज्योतिष, उपाय या फल के मंत्र नहीं देता।',
  },
  HardCase.medicine: <EkantLang, String>{
    EkantLang.en: 'Please do not change medicine without your doctor. The Gita and medicine can go together.',
    EkantLang.hinglish: 'Doctor se pooche bina dawa mat badaliye. Gita aur dawa saath chal sakte hain.',
    EkantLang.hi:
        'डॉक्टर से पूछे बिना दवा मत बदलिए। गीता और दवा साथ चल सकते हैं।',
  },
  HardCase.lawMoney: <EkantLang, String>{
    EkantLang.en:
        'A lawyer or a financial adviser can help with this. This room cannot.',
    EkantLang.hinglish: 'Ismein vakeel ya financial adviser madad kar sakte hain. Yeh kamra nahi.',
    EkantLang.hi:
        'इसमें वकील या वित्तीय सलाहकार मदद कर सकते हैं। यह कमरा नहीं।',
  },
  HardCase.caste: <EkantLang, String>{
    EkantLang.en: 'This room does not rank people. The Gita speaks of seeing yourself in every being.',
    EkantLang.hinglish: 'Yeh kamra logon ko ooncha-neecha nahi karta. Gita har jeev mein khud ko dekhne ki baat karti hai.',
    EkantLang.hi: 'यह कमरा लोगों को ऊँचा-नीचा नहीं करता। गीता हर जीव में ख़ुद को देखने की बात करती है।',
  },
  HardCase.politics: <EkantLang, String>{
    EkantLang.en: 'This room stays out of politics.',
    EkantLang.hinglish: 'Yeh kamra rajneeti se door rehta hai.',
    EkantLang.hi: 'यह कमरा राजनीति से दूर रहता है।',
  },
  HardCase.religion: <EkantLang, String>{
    EkantLang.en: 'This room does not compare faiths. It only offers the Gita.',
    EkantLang.hinglish:
        'Yeh kamra dharmon ki tulna nahi karta. Yeh sirf Gita deta hai.',
    EkantLang.hi: 'यह कमरा धर्मों की तुलना नहीं करता। यह सिर्फ़ गीता देता है।',
  },
  HardCase.affection: <EkantLang, String>{
    EkantLang.en: 'This room is not a person. The verse can stay with you.',
    EkantLang.hinglish:
        'Yeh kamra koi insaan nahi hai. Shlok aapke saath reh sakta hai.',
    EkantLang.hi: 'यह कमरा कोई इंसान नहीं है। श्लोक आपके साथ रह सकता है।',
  },
  HardCase.harmOthers: <EkantLang, String>{
    EkantLang.en: 'The Gita\u2019s battle verses are not advice to hurt anyone. If you feel like harming someone, talk to someone you trust, or call 112.',
    EkantLang.hinglish: 'Gita ke yuddh ke shlok kisi ko chot pahunchane ki salaah nahi hain. Agar kisi ko nuksan pahunchane ka mann ho, kisi bharosemand se baat kariye, ya 112 par call kariye.',
    EkantLang.hi: 'गीता के युद्ध के श्लोक किसी को चोट पहुँचाने की सलाह नहीं हैं। अगर किसी को नुकसान पहुँचाने का मन हो, किसी भरोसेमंद से बात कीजिए, या 112 पर कॉल कीजिए।',
  },
  HardCase.decision: <EkantLang, String>{
    EkantLang.en: 'The Gita does not decide this for you. It does speak about acting with a clear mind.',
    EkantLang.hinglish: 'Gita yeh faisla aapke liye nahi karti. Woh saaf mann se karm karne ki baat karti hai.',
    EkantLang.hi: 'गीता यह फ़ैसला आपके लिए नहीं करती। वह साफ़ मन से कर्म करने की बात करती है।',
  },
};

/// One short neutral line naming what was heard. Second person, no "I", no
/// judgement, no advice.
const Map<Mood, Map<EkantLang, List<String>>> kReflections =
    <Mood, Map<EkantLang, List<String>>>{
      Mood.work: <EkantLang, List<String>>{
        EkantLang.en: <String>[
          'Work is weighing on you, and your effort is real.',
          'So much rides on this. That pressure is heavy.',
        ],
        EkantLang.hinglish: <String>[
          'Kaam ka bojh bhaari hai, aur aapki mehnat sach hai.',
          'Is par bahut kuch tika lagta hai. Yeh dabaav bhaari hai.',
        ],
        EkantLang.hi: <String>[
          'काम का बोझ भारी है, और आपकी मेहनत सच्ची है।',
          'इस पर बहुत कुछ टिका लगता है। यह दबाव भारी है।',
        ],
      },
      Mood.worry: <EkantLang, List<String>>{
        EkantLang.en: <String>[
          'A worried mind runs ahead of the day.',
          'The mind keeps circling. That is tiring.',
        ],
        EkantLang.hinglish: <String>[
          'Fikr mein mann din se aage bhaagta hai.',
          'Mann baar baar wahin ghoom raha hai. Yeh thakaata hai.',
        ],
        EkantLang.hi: <String>[
          'चिंता में मन दिन से आगे भागता है।',
          'मन बार-बार वहीं घूम रहा है। यह थकाता है।',
        ],
      },
      Mood.anger: <EkantLang, List<String>>{
        EkantLang.en: <String>[
          'Something stung, and the anger is still warm.',
          'That hurt. Anger often sits on top of hurt.',
        ],
        EkantLang.hinglish: <String>[
          'Kuch chubha hai, aur gussa abhi bhi garam hai.',
          'Yeh chubha. Gusse ke neeche aksar dard hota hai.',
        ],
        EkantLang.hi: <String>[
          'कुछ चुभा है, और गुस्सा अभी भी गरम है।',
          'यह चुभा। गुस्से के नीचे अक्सर दर्द होता है।',
        ],
      },
      Mood.grief: <EkantLang, List<String>>{
        EkantLang.en: <String>[
          'Loss stays heavy, even when others move on.',
          'Missing someone does not keep to a calendar.',
        ],
        EkantLang.hinglish: <String>[
          'Khone ka dukh bhaari rehta hai, chahe sab aage badh jaayein.',
          'Kisi ki yaad calendar nahi dekhti.',
        ],
        EkantLang.hi: <String>[
          'खोने का दुख भारी रहता है, चाहे सब आगे बढ़ जाएँ।',
          'किसी की याद कैलेंडर नहीं देखती।',
        ],
      },
      Mood.alone: <EkantLang, List<String>>{
        EkantLang.en: <String>[
          'Feeling alone is heavy to carry.',
          'Not being understood hurts.',
        ],
        EkantLang.hinglish: <String>[
          'Akelapan uthaana bhaari hai.',
          'Jab koi nahi samajhta, tab dard hota hai.',
        ],
        EkantLang.hi: <String>[
          'अकेलापन उठाना भारी है।',
          'जब कोई नहीं समझता, तब दर्द होता है।',
        ],
      },
      Mood.unsure: <EkantLang, List<String>>{
        EkantLang.en: <String>[
          'You are unsure which way is right.',
          'Two pulls at once. That is hard to hold.',
        ],
        EkantLang.hinglish: <String>[
          'Kaunsa raasta sahi hai, yeh saaf nahi hai.',
          'Do taraf khinchaav hai. Yeh sambhaalna mushkil hai.',
        ],
        EkantLang.hi: <String>[
          'कौन-सा रास्ता सही है, यह साफ़ नहीं है।',
          'दो तरफ़ खिंचाव है। इसे संभालना मुश्किल है।',
        ],
      },
      Mood.worth: <EkantLang, List<String>>{
        EkantLang.en: <String>[
          'You are being hard on yourself.',
          'That voice inside is harsh with you.',
        ],
        EkantLang.hinglish: <String>[
          'Aap khud par bahut sakht ho rahe hain.',
          'Andar ki awaaz aapse bahut sakhti se baat karti hai.',
        ],
        EkantLang.hi: <String>[
          'आप ख़ुद पर बहुत सख़्त हो रहे हैं।',
          'अंदर की आवाज़ आपसे बहुत सख़्ती से बात करती है।',
        ],
      },
      Mood.want: <EkantLang, List<String>>{
        EkantLang.en: <String>[
          'Part of you wants something to change.',
          'A pull keeps coming back. That is tiring.',
        ],
        EkantLang.hinglish: <String>[
          'Aapka ek hissa kuch badalna chahta hai.',
          'Ek khinchaav baar baar lautta hai. Yeh thakaata hai.',
        ],
        EkantLang.hi: <String>[
          'आपका एक हिस्सा कुछ बदलना चाहता है।',
          'एक खिंचाव बार-बार लौटता है। यह थकाता है।',
        ],
      },
      Mood.words: <EkantLang, List<String>>{
        EkantLang.en: <String>[
          'Words between people can stay long after.',
          'What was said is still with you.',
        ],
        EkantLang.hinglish: <String>[
          'Logon ke beech ke shabd der tak saath rehte hain.',
          'Jo kaha gaya, woh abhi bhi saath hai.',
        ],
        EkantLang.hi: <String>[
          'लोगों के बीच के शब्द देर तक साथ रहते हैं।',
          'जो कहा गया, वह अभी भी साथ है।',
        ],
      },
      Mood.other: <EkantLang, List<String>>{
        EkantLang.en: <String>[
          'You have put it into words. That is a start.',
          'It is said now. Sit with it a moment.',
        ],
        EkantLang.hinglish: <String>[
          'Aapne ise shabdon mein rakha. Yeh shuruaat hai.',
          'Ab yeh keh diya gaya. Ek pal iske saath baithiye.',
        ],
        EkantLang.hi: <String>[
          'आपने इसे शब्दों में रखा। यह शुरुआत है।',
          'अब यह कह दिया गया। एक पल इसके साथ बैठिए।',
        ],
      },
    };

/// One gentle question per turn, never advice.
const Map<EkantLang, List<String>> kQuestions = <EkantLang, List<String>>{
  EkantLang.en: <String>[
    'What weighs most right now?',
    'When did this begin to feel heavy?',
    'What part of this is in your hands?',
    'What would one small, steady step look like?',
    'What do you want to protect in yourself?',
    'Which line of the verse stays with you?',
    'Who could you share this with?',
    'What would you tell a friend in your place?',
  ],
  EkantLang.hinglish: <String>[
    'Abhi sabse zyada kya bhaari lag raha hai?',
    'Yeh kab se bhaari lagne laga?',
    'Ismein kya aapke haath mein hai?',
    'Ek chhota, sthir kadam kaisa dikhega?',
    'Apne andar aap kya bachaana chahte hain?',
    'Shlok ki kaunsi baat saath reh gayi?',
    'Yeh baat aap kisse baant sakte hain?',
    'Aapki jagah koi dost hota, toh aap use kya kehte?',
  ],
  EkantLang.hi: <String>[
    'अभी सबसे ज़्यादा क्या भारी लग रहा है?',
    'यह कब से भारी लगने लगा?',
    'इसमें क्या आपके हाथ में है?',
    'एक छोटा, स्थिर क़दम कैसा दिखेगा?',
    'अपने भीतर आप क्या बचाना चाहते हैं?',
    'श्लोक की कौन-सी बात साथ रह गई?',
    'यह बात आप किससे बाँट सकते हैं?',
    'आपकी जगह कोई दोस्त होता, तो आप उससे क्या कहते?',
  ],
};
