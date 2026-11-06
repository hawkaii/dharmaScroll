import '../../domain/models/verse.dart';

/// Ten real verses, fully tagged.
///
/// This stands in for `assets/verses/gita_seed.json` until the content owner
/// lands the seed set. Every card, sheet and checkpoint is testable against it,
/// which is the whole point of building screens at ten verses rather than
/// waiting for 108.
const List<Verse> kFakeVerses = <Verse>[
  Verse(
    id: '2.47',
    chapter: 2,
    number: 47,
    yogaName: 'Sankhya Yoga',
    padas: <String>[
      'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।',
      'मा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥',
    ],
    iast: 'karmaṇy-evādhikāras te mā phaleṣu kadācana',
    meaningHi: 'तुम्हारा अधिकार सिर्फ़ कर्म पर है, उसके फल पर कभी नहीं।',
    meaningEn: 'You have a right to your work, never to its results.',
    lessonHi:
        'सामने जो काम है, उसे पूरी ताकत से करो। नतीजा तुम्हारे हाथ में पूरा नहीं है, '
        'इसलिए अपनी शांति उससे मत बांधो। और इसे बहाना बनाकर काम छोड़ना भी मत।',
    lessonEn:
        'Do the work in front of you with full effort. The result is not fully '
        'in your hands, so don\'t tie your peace to it. And don\'t use that as '
        'an excuse to stop working either.',
    context:
        'Krishna to Arjuna, on the battlefield, right after Arjuna says he would '
        'rather not fight than face the outcome.',
    speaker: 'Krishna',
    listener: 'Arjuna',
    wordMeanings: <WordMeaning>[
      WordMeaning(
        word: 'कर्मणि',
        meaningHi: 'कर्म में',
        meaningEn: 'in action',
      ),
      WordMeaning(word: 'एव', meaningHi: 'ही', meaningEn: 'alone'),
      WordMeaning(word: 'अधिकारः', meaningHi: 'अधिकार', meaningEn: 'right'),
      WordMeaning(word: 'ते', meaningHi: 'तुम्हारा', meaningEn: 'your'),
      WordMeaning(
        word: 'फलेषु',
        meaningHi: 'फलों में',
        meaningEn: 'in the fruits',
      ),
      WordMeaning(word: 'कदाचन', meaningHi: 'कभी भी', meaningEn: 'ever'),
    ],
    emotionTags: <String>['anxiety', 'pressure', 'self-doubt'],
    situationTags: <String>['work', 'results', 'perfectionism'],
    difficulty: 1,
  ),
  Verse(
    id: '2.48',
    chapter: 2,
    number: 48,
    yogaName: 'Sankhya Yoga',
    padas: <String>[
      'योगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय।',
      'सिद्ध्यसिद्ध्योः समो भूत्वा समत्वं योग उच्यते॥',
    ],
    iast: 'yoga-sthaḥ kuru karmāṇi saṅgaṁ tyaktvā dhanañjaya',
    meaningHi: 'सफलता और असफलता में एक जैसा रहना, यही योग है।',
    meaningEn:
        'Stay steady whether it works out or not. That evenness is yoga.',
    lessonHi:
        'आज जो जीत मिली, उसे पूरा मनाओ। फिर याद रखो: वही तुम जिसने यह जीता, '
        'उसी ने पहले दो बार हार भी मानी थी। जीत तुम्हारी पहचान नहीं बननी चाहिए, '
        'जैसे हार नहीं बनी।',
    lessonEn:
        'Celebrate fully. Then notice: the same you who cleared this also failed '
        'before. Samatvam means the win doesn\'t become your identity any more '
        'than the losses did. That keeps next week\'s nerves small.',
    context:
        'Krishna continues the same teaching: act from steadiness, not from the '
        'hope of a result.',
    speaker: 'Krishna',
    listener: 'Arjuna',
    wordMeanings: <WordMeaning>[
      WordMeaning(
        word: 'योगस्थः',
        meaningHi: 'योग में स्थित',
        meaningEn: 'steadfast in yoga',
      ),
      WordMeaning(word: 'समत्वम्', meaningHi: 'समानता', meaningEn: 'evenness'),
      WordMeaning(
        word: 'उच्यते',
        meaningHi: 'कहा जाता है',
        meaningEn: 'is called',
      ),
    ],
    emotionTags: <String>['joy', 'pride', 'anticipation'],
    situationTags: <String>['success', 'results', 'exam'],
    difficulty: 2,
  ),
  Verse(
    id: '2.50',
    chapter: 2,
    number: 50,
    yogaName: 'Sankhya Yoga',
    padas: <String>[
      'बुद्धियुक्तो जहातीह उभे सुकृतदुष्कृते।',
      'तस्माद्योगाय युज्यस्व योगः कर्मसु कौशलम्॥',
    ],
    iast: 'buddhi-yukto jahātīha ubhe sukṛta-duṣkṛte',
    meaningHi: 'योग का मतलब है कर्म में कुशलता।',
    meaningEn: 'Yoga is skill in action.',
    lessonHi:
        'कुशलता का मतलब कम मेहनत नहीं, सही मेहनत है। जो काम तुम कर रहे हो, '
        'उसे थोड़ा और अच्छा करने का एक तरीका आज चुनो — ज्यादा घंटे नहीं, बेहतर तरीका।',
    lessonEn:
        'Skill is not less effort, it is the right effort. Pick one way to do '
        'today\'s work slightly better — not more hours, a better method.',
    context:
        'The verse that named the app\'s splash screen. Krishna closes the '
        'argument about acting without attachment.',
    speaker: 'Krishna',
    listener: 'Arjuna',
    wordMeanings: <WordMeaning>[
      WordMeaning(word: 'कौशलम्', meaningHi: 'कुशलता', meaningEn: 'skill'),
      WordMeaning(
        word: 'कर्मसु',
        meaningHi: 'कर्मों में',
        meaningEn: 'in actions',
      ),
    ],
    emotionTags: <String>['focus', 'confusion'],
    situationTags: <String>['work', 'craft', 'study'],
    difficulty: 1,
  ),
  Verse(
    id: '2.55',
    chapter: 2,
    number: 55,
    yogaName: 'Sankhya Yoga',
    padas: <String>[
      'प्रजहाति यदा कामान्सर्वान्पार्थ मनोगतान्।',
      'आत्मन्येवात्मना तुष्टः स्थितप्रज्ञस्तदोच्यते॥',
    ],
    iast: 'prajahāti yadā kāmān sarvān pārtha mano-gatān',
    meaningHi:
        'जब मन की सारी लालसाएँ शांत हो जाएँ, तब मनुष्य स्थितप्रज्ञ कहलाता है।',
    meaningEn: 'When the mind\'s cravings fall quiet, that is sthitaprajna.',
    lessonHi:
        'शांति इच्छाओं के पूरा होने से नहीं आती, इच्छाओं के शांत होने से आती है। '
        'आज एक चीज़ जो तुम "चाहते" हो, उसे एक दिन के लिए भूलकर देखो कि दिन कैसा बीतता है।',
    lessonEn:
        'Peace does not arrive when cravings are fulfilled, but when they '
        'quieten. Today, put one thing you want aside for a day and notice how '
        'the day feels.',
    context:
        'Arjuna asks how a steady-minded person speaks, sits and walks. This is '
        'the first line of Krishna\'s answer.',
    speaker: 'Krishna',
    listener: 'Arjuna',
    wordMeanings: <WordMeaning>[
      WordMeaning(
        word: 'स्थितप्रज्ञः',
        meaningHi: 'स्थिर बुद्धि वाला',
        meaningEn: 'steady in wisdom',
      ),
      WordMeaning(word: 'कामान्', meaningHi: 'इच्छाएँ', meaningEn: 'desires'),
    ],
    emotionTags: <String>['restlessness', 'craving'],
    situationTags: <String>['peace', 'discipline'],
    difficulty: 3,
  ),
  Verse(
    id: '3.21',
    chapter: 3,
    number: 21,
    yogaName: 'Karma Yoga',
    padas: <String>[
      'यद्यदाचरति श्रेष्ठस्तत्तदेवेतरो जनः।',
      'स यत्प्रमाणं कुरुते लोकस्तदनुवर्तते॥',
    ],
    iast: 'yad yad ācarati śreṣṭhas tat tad evetaro janaḥ',
    meaningHi: 'श्रेष्ठ व्यक्ति जैसा करता है, बाकी लोग वैसा ही करते हैं।',
    meaningEn: 'Whatever leaders do, others follow.',
    lessonHi:
        'लोग सुनते नहीं, देखते हैं। तुम्हारा छोटा भाई, जूनियर या दोस्त वही करेगा '
        'जो तुम करते हो। आज एक आदत चुनो जो तुम चाहोगे कि कोई कॉपी करे।',
    lessonEn:
        'People copy what leaders do, not what they say. Your younger cousin '
        'copies how you treat your phone at dinner, how you talk to your mother, '
        'how you handle a loss. You are already someone\'s shreshtha. Pick one '
        'habit today you would be proud to see copied.',
    context:
        'Krishna points to King Janaka, who kept doing his duty after '
        'enlightenment, because the kingdom was watching.',
    speaker: 'Krishna',
    listener: 'Arjuna',
    wordMeanings: <WordMeaning>[
      WordMeaning(
        word: 'श्रेष्ठः',
        meaningHi: 'श्रेष्ठ, नेता',
        meaningEn: 'the best, a leader',
      ),
      WordMeaning(
        word: 'प्रमाणम्',
        meaningHi: 'मानक',
        meaningEn: 'standard, example',
      ),
      WordMeaning(
        word: 'अनुवर्तते',
        meaningHi: 'पीछे चलता है',
        meaningEn: 'follows',
      ),
    ],
    emotionTags: <String>['responsibility', 'pride'],
    situationTags: <String>['leadership', 'family', 'work'],
    difficulty: 2,
  ),
  Verse(
    id: '3.35',
    chapter: 3,
    number: 35,
    yogaName: 'Karma Yoga',
    padas: <String>[
      'श्रेयान्स्वधर्मो विगुणः परधर्मात्स्वनुष्ठितात्।',
      'स्वधर्मे निधनं श्रेयः परधर्मो भयावहः॥',
    ],
    iast: 'śreyān sva-dharmo viguṇaḥ para-dharmāt sv-anuṣṭhitāt',
    meaningHi: 'अपना धर्म अधूरा करना दूसरे का धर्म पूरी तरह करने से बेहतर है।',
    meaningEn:
        'Better your own path done imperfectly than another\'s done well.',
    lessonHi:
        'किसी और की ज़िंदगी तुम्हारा पैमाना नहीं है। अगर तुम अपने दोस्त की सफलता '
        'देखकर पीछे महसूस करते हो, तो यह श्लोक तुम्हें अपनी रेस दौड़ने की इजाज़त देता है।',
    lessonEn:
        '\u201CBetter your own path done imperfectly than someone else\'s done '
        'well.\u201D His path is not your measuring stick. The verse gives you '
        'permission to run your own race.',
    context:
        'Krishna warns against copying another\'s duty because it looks more '
        'prestigious.',
    speaker: 'Krishna',
    listener: 'Arjuna',
    wordMeanings: <WordMeaning>[
      WordMeaning(
        word: 'स्वधर्मः',
        meaningHi: 'अपना धर्म',
        meaningEn: 'own duty',
      ),
      WordMeaning(
        word: 'परधर्मात्',
        meaningHi: 'दूसरे के धर्म से',
        meaningEn: 'than another\'s duty',
      ),
    ],
    emotionTags: <String>['envy', 'comparison', 'low self-worth'],
    situationTags: <String>['career', 'friendship', 'social media'],
    difficulty: 2,
  ),
  Verse(
    id: '6.5',
    chapter: 6,
    number: 5,
    yogaName: 'Dhyana Yoga',
    padas: <String>[
      'उद्धरेदात्मनात्मानं नात्मानमवसादयेत्।',
      'आत्मैव ह्यात्मनो बन्धुरात्मैव रिपुरात्मनः॥',
    ],
    iast: 'uddhared ātmanātmānaṁ nātmānam avasādayet',
    meaningHi: 'अपने आप को खुद उठाओ, खुद को गिरने मत दो। तुम ही अपने मित्र हो, तुम ही अपने शत्रु।',
    meaningEn: 'Lift yourself by yourself. You are your own friend and your own enemy.',
    lessonHi:
        'रात के एक बजे वह आवाज़ जो कहती है "सब तुमसे आगे हैं" — वह रिपु है। '
        'जो कहती है "फ़ोन बंद करो, सो जाओ, कल पाँच श्लोक" — वह बंधु है। '
        'मन एक ही है। तुम चुनते हो किसे माइक मिलेगा।',
    lessonEn:
        'Lift yourself up with your own mind. Don\'t let yourself sink. The same '
        'mind can be your best friend or your worst enemy, depending on how you '
        'train it.',
    context:
        'The opening of the chapter on meditation. Before any technique, Krishna '
        'says the first job is to stop being your own saboteur.',
    speaker: 'Krishna',
    listener: 'Arjuna',
    wordMeanings: <WordMeaning>[
      WordMeaning(
        word: 'उद्धरेत्',
        meaningHi: 'ऊपर उठाए',
        meaningEn: 'should lift',
      ),
      WordMeaning(word: 'बन्धुः', meaningHi: 'मित्र', meaningEn: 'friend'),
      WordMeaning(word: 'रिपुः', meaningHi: 'शत्रु', meaningEn: 'enemy'),
    ],
    emotionTags: <String>['low', 'self-doubt', 'anxiety'],
    situationTags: <String>['late night', 'exam', 'mental health'],
    difficulty: 2,
  ),
  Verse(
    id: '12.13',
    chapter: 12,
    number: 13,
    yogaName: 'Bhakti Yoga',
    padas: <String>[
      'अद्वेष्टा सर्वभूतानां मैत्रः करुण एव च।',
      'निर्ममो निरहङ्कारः समदुःखसुखः क्षमी॥',
    ],
    iast: 'adveṣṭā sarva-bhūtānāṁ maitraḥ karuṇa eva ca',
    meaningHi: 'जो किसी से द्वेष नहीं करता, सबका मित्र और दयालु है।',
    meaningEn: 'One who hates none, is friendly and compassionate to all.',
    lessonHi:
        'करुणा का मतलब सबको खुश करना नहीं है। इसका मतलब है कि जो तुम्हें चोट पहुँचाता है, '
        'उसे भी वही इंसान समझना जो अपने डर से चल रहा है — और फिर भी सीमा रखना।',
    lessonEn:
        'Compassion is not pleasing everyone. It is seeing that the person who '
        'hurt you is also running on their own fear, and still keeping your '
        'boundary.',
    context:
        'Krishna describes the devotee he loves — starting with the absence of '
        'hatred.',
    speaker: 'Krishna',
    listener: 'Arjuna',
    wordMeanings: <WordMeaning>[
      WordMeaning(word: 'मैत्रः', meaningHi: 'मित्रवत', meaningEn: 'friendly'),
      WordMeaning(
        word: 'करुणः',
        meaningHi: 'दयालु',
        meaningEn: 'compassionate',
      ),
    ],
    emotionTags: <String>['anger', 'hurt', 'forgiveness'],
    situationTags: <String>['relationships', 'conflict'],
    difficulty: 2,
  ),
  Verse(
    id: '12.15',
    chapter: 12,
    number: 15,
    yogaName: 'Bhakti Yoga',
    padas: <String>[
      'यस्मान्नोद्विजते लोको लोकान्नोद्विजते च यः।',
      'हर्षामर्षभयोद्वेगैर्मुक्तो यः स च मे प्रियः॥',
    ],
    iast: 'yasmān nodvijate loko lokān nodvijate ca yaḥ',
    meaningHi: 'जिससे कोई डरता नहीं, जो किसी से डरता नहीं — वही मुझे प्रिय है।',
    meaningEn: 'One whom the world does not disturb, and who does not disturb the world.',
    lessonHi:
        'शांत इंसान वह नहीं जो कुछ महसूस नहीं करता। वह है जो महसूस करके भी किसी पर '
        'नहीं डालता। आज एक बार गुस्सा आने पर उसे अपने अंदर रुकने दो, बाहर नहीं।',
    lessonEn:
        'A steady person is not someone who feels nothing. It is someone who '
        'feels it and does not put it on someone else. Today, when the anger '
        'comes, let it stop inside you instead of leaving.',
    context:
        'Krishna continues describing the devotee: unshaken by excitement, envy '
        'or fear.',
    speaker: 'Krishna',
    listener: 'Arjuna',
    wordMeanings: <WordMeaning>[
      WordMeaning(word: 'हर्ष', meaningHi: 'खुशी', meaningEn: 'joy'),
      WordMeaning(
        word: 'उद्वेगैः',
        meaningHi: 'बेचैनी से',
        meaningEn: 'from agitation',
      ),
    ],
    emotionTags: <String>['anger', 'agitation'],
    situationTags: <String>['family', 'work', 'conflict'],
    difficulty: 2,
  ),
  Verse(
    id: '18.66',
    chapter: 18,
    number: 66,
    yogaName: 'Moksha Sannyasa Yoga',
    padas: <String>[
      'सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज।',
      'अहं त्वां सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः॥',
    ],
    iast: 'sarva-dharmān parityajya mām ekaṁ śaraṇaṁ vraja',
    meaningHi: 'सब धर्मों को छोड़कर मेरी शरण में आ जाओ। मैं तुम्हें सब पापों से मुक्त कर दूँगा, शोक मत करो।',
    meaningEn: 'Come to me alone for refuge. Do not grieve.',
    lessonHi:
        'यह श्लोक पूरी गीता का अंत है और उसका सबसे आसान हिस्सा: "शोक मत करो।" '
        'आज जिस बात पर तुम खुद को कोस रहे हो, उसे एक बार किसी ऐसे इंसान से कहो जो तुम्हें बिना जज किए सुने।',
    lessonEn:
        'The last instruction of the Gita is also its simplest: do not grieve. '
        'Today, say the thing you are blaming yourself for to one person who '
        'will listen without judging.',
    context: 'The final verse of Krishna\'s teaching, before the Gita ends.',
    speaker: 'Krishna',
    listener: 'Arjuna',
    wordMeanings: <WordMeaning>[
      WordMeaning(word: 'शरणम्', meaningHi: 'शरण', meaningEn: 'refuge'),
      WordMeaning(
        word: 'मा शुचः',
        meaningHi: 'शोक मत करो',
        meaningEn: 'do not grieve',
      ),
    ],
    emotionTags: <String>['grief', 'guilt', 'relief'],
    situationTags: <String>['faith', 'loss', 'forgiveness'],
    difficulty: 2,
  ),
];
