// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get back => 'वापस';

  @override
  String get skip => 'छोड़ें';

  @override
  String get continueLabel => 'आगे बढ़ें';

  @override
  String whatIs(String topic) {
    return '$topic क्या है?';
  }

  @override
  String progressOf(int n, int total) {
    return '$total में से $n';
  }

  @override
  String get on => 'चालू';

  @override
  String get off => 'बंद';

  @override
  String get comingSoon => 'जल्द आ रही है';

  @override
  String get moreLanguages => 'और भाषाएँ';

  @override
  String languageSoonSemantic(String name) {
    return '$name, जल्द आ रही है, अभी तैयार नहीं';
  }

  @override
  String get textSizeRow => 'अक्षरों का आकार';

  @override
  String get textSizeEyebrow => 'अक्षरों का आकार';

  @override
  String get textSizeTitle => 'शब्द कितने\nबड़े चाहिए?';

  @override
  String get textSizeWhy =>
      'वह आकार चुनिए जो आँखों को आसान लगे। इसे बाद में बदल सकते हैं।';

  @override
  String get textSizeNormal => 'सामान्य';

  @override
  String get textSizeLarge => 'बड़ा';

  @override
  String get textSizeExtraLarge => 'बहुत बड़ा';

  @override
  String get textSizeSample =>
      'दीया जल गया है। पाँच श्लोक आपकी राह देख रहे हैं।';

  @override
  String get textSizeRowWhy => 'शब्दों को बड़ा या छोटा कीजिए।';

  @override
  String get welcomeLine1 => 'एक संवाद';

  @override
  String get welcomeLine2 => 'रणभूमि में।';

  @override
  String get welcomeSub => 'पाँच हज़ार साल पुराना।\nआइए, सुनिए।';

  @override
  String get welcomeButton => 'सुनिए';

  @override
  String get eyebrowLight => 'आपकी ज्योति';

  @override
  String get eyebrowCity => 'आपका शहर';

  @override
  String get eyebrowTradition => 'आपकी परंपरा';

  @override
  String get eyebrowHour => 'आपका समय';

  @override
  String get signInTitle => 'दीया कौन\nजला रहा है?';

  @override
  String get cityTitle => 'आप किस शहर में\nरहते हैं?';

  @override
  String get traditionTitle => 'आप एकादशी\nकैसे मनाते हैं?';

  @override
  String get reminderTitle => 'आपका दिन\nकब शुरू होता है?';

  @override
  String get finishLabel => 'पहला दीया जलाइए';

  @override
  String get whySignIn =>
      'साइन इन करने से फ़ोन बदलने पर भी आपका दीया और आपके श्लोक सुरक्षित रहेंगे। अभी सब कुछ इसी फ़ोन में रहता है।';

  @override
  String get whyCity =>
      'आपके शहर से हमें पता चलता है कि आपके यहाँ सूरज कब उगता है। पूजा का समय सूरज के साथ चलता है।';

  @override
  String get whyTradition =>
      'परिवार एकादशी का व्रत दो तरह से रखते हैं। कुछ महीनों में दिन अलग हो जाते हैं।';

  @override
  String get whyHour =>
      'इस समय पाँच श्लोक आपकी राह देखेंगे। हर दिन वही शांत समय।';

  @override
  String get seeDifference => 'अंतर देखिए';

  @override
  String get topicSmartaVaishnava => 'स्मार्त और वैष्णव';

  @override
  String get traditionSmarta => 'स्मार्त';

  @override
  String get traditionVaishnava => 'वैष्णव';

  @override
  String get traditionUnsure => 'पता नहीं';

  @override
  String get hintSmarta =>
      'जिस दिन सूर्योदय के समय एकादशी हो, उसी दिन व्रत रखें।';

  @override
  String get hintVaishnava => 'सुबह से शुद्ध एकादशी का इंतज़ार करें।';

  @override
  String get hintUnsure => 'जब दो दिन हों, तो हम दोनों दिखाएँगे।';

  @override
  String get dragToChangeAm => 'AM  ·  बदलने के लिए सरकाइए';

  @override
  String get dragToChangePm => 'PM  ·  बदलने के लिए सरकाइए';

  @override
  String get reminderTimeLabel => 'याद दिलाने का समय';

  @override
  String get earlier15 => '15 मिनट पहले';

  @override
  String get later15 => '15 मिनट बाद';

  @override
  String get searchCity => 'शहर खोजिए';

  @override
  String get signInGoogle => 'Google से जारी रखें';

  @override
  String get signInPhone => 'फ़ोन नंबर से जारी रखें';

  @override
  String get signInGuest => 'अतिथि के रूप में जारी रखें';

  @override
  String get sendCode => 'कोड भेजिए';

  @override
  String get verify => 'जाँचिए';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get codeNote => 'हम इस फ़ोन पर छह अंकों का कोड भेजेंगे।';

  @override
  String codeSentTo(String phone) {
    return '$phone पर कोड भेजा गया';
  }

  @override
  String get otherWays => 'साइन इन का दूसरा तरीका';

  @override
  String get changeNumber => 'नंबर बदलिए';

  @override
  String get sixNumberCode => 'छह अंकों का कोड';

  @override
  String practiceEyebrow(int n, int total) {
    return 'आपकी साधना  ·  $total में से $n';
  }

  @override
  String get practiceQ1 => 'क्या आप व्रत\nरखते हैं?';

  @override
  String get practiceQ2 => 'कौन-सा दिन\nआपका अपना है?';

  @override
  String get practiceQ3 => 'क्या आप शाम को\nदीया जलाते हैं?';

  @override
  String get practiceQ4 => 'सूर्योदय पर\nएक शांत पल?';

  @override
  String get practiceQ5 => 'पूर्णिमा और\nबड़े त्योहार?';

  @override
  String get practiceWhy1 =>
      'एकादशी चंद्रमा की ग्यारहवीं तिथि है। यह महीने में दो बार आती है। बहुत से लोग इस दिन व्रत रखते हैं।';

  @override
  String get practiceWhy2 =>
      'बहुत से घरों में सप्ताह का एक दिन किसी एक देवता का माना जाता है। एक चुनिए, या कोई नहीं।';

  @override
  String get practiceWhy3 =>
      'शाम वह समय है जब दिन रात में बदलता है। उस समय छोटा दीया जलाना धन्यवाद कहने का पुराना तरीका है।';

  @override
  String get practiceWhy4 =>
      'संध्या का अर्थ है रात और दिन का मिलन। सूरज उगते समय एक शांत मिनट।';

  @override
  String get practiceWhy5 =>
      'पूर्णिमा पूरे चाँद की रात है। अमावस्या वह रात है जब चाँद नहीं दिखता। दिवाली जैसे बड़े त्योहार इन्हीं दिनों में आते हैं।';

  @override
  String get yesEkadashi => 'हाँ, एकादशी पर';

  @override
  String get yesEvenings => 'हाँ, ज़्यादातर शामों को';

  @override
  String get yesPlease => 'हाँ, ज़रूर';

  @override
  String get yesTellMe => 'हाँ, बताइए';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get noDay => 'अभी कोई दिन नहीं';

  @override
  String get dayMonday => 'सोमवार';

  @override
  String get dayTuesday => 'मंगलवार';

  @override
  String get dayThursday => 'गुरुवार';

  @override
  String get daySaturday => 'शनिवार';

  @override
  String get godShiva => 'शिव';

  @override
  String get godHanuman => 'हनुमान';

  @override
  String get godVishnu => 'विष्णु, गुरु';

  @override
  String get godShani => 'शनि';

  @override
  String get firstNoteTag => 'आपका पहला संदेश';

  @override
  String firstNoteSemantic(String when, String body) {
    return 'आपका पहला संदेश। $when। $body';
  }

  @override
  String get timedToSun => 'आपके सूरज के हिसाब से';

  @override
  String get timeFromCity => 'हम आपके शहर से समय तय करेंगे।';

  @override
  String get nothingSoon =>
      'अगले कुछ हफ़्तों में कुछ नहीं है। जब आएगा, हम बताएँगे।';

  @override
  String get tabToday => 'आज';

  @override
  String get tabYatra => 'यात्रा';

  @override
  String get tabYou => 'आप';

  @override
  String get todayBegin => 'आज की साधना शुरू कीजिए';

  @override
  String get todayContinue => 'साधना जारी रखिए';

  @override
  String get todayAgain => 'फिर से जलाइए';

  @override
  String get todayHearAgain => 'फिर से सुनिए';

  @override
  String get todayDoneTitle => 'आज का दीया जल गया।';

  @override
  String get todayCameBack => 'आप लौट आए।';

  @override
  String get todayWalkedTitle => 'दीया जल गया।\nअब अपने मन की बात कहिए।';

  @override
  String get todayHeardTitle => 'पाँच श्लोक सुन लिए।\nअब पथ पर\nएक कदम बढ़ाइए।';

  @override
  String get greetMorning => 'सुप्रभात।';

  @override
  String greetMorningName(String name) {
    return 'सुप्रभात, $name।';
  }

  @override
  String get greetNamaste => 'नमस्ते।';

  @override
  String greetNamasteName(String name) {
    return 'नमस्ते, $name।';
  }

  @override
  String get todaySubBack => 'दीया अभी भी गर्म था।';

  @override
  String get todaySubDone => 'कल फिर आइए।\nश्लोक आपकी राह देखेंगे।';

  @override
  String get todaySubWalked => 'एक श्लोक उत्तर देगा।';

  @override
  String get todaySubStart =>
      'पाँच श्लोक राह देख रहे हैं।\nफिर आप विश्राम कीजिए।';

  @override
  String topDay(int n) {
    return 'दिन $n';
  }

  @override
  String topAdhyaya(int n) {
    return 'अध्याय $n';
  }

  @override
  String calendarToday(String items) {
    return 'आज आपके पंचांग में: $items';
  }

  @override
  String pointsAction(int n) {
    return '$n मोक्ष अंक';
  }

  @override
  String get ekantAction => 'एकांत, एक शांत कमरा';

  @override
  String daysKept(int n) {
    return 'आपके $n दिन सहेजे हुए हैं।';
  }

  @override
  String get earlierDaysKept => 'आपके पिछले दिन सहेजे हुए हैं।';

  @override
  String get railHear => 'सुनिए';

  @override
  String get railWalk => 'चलिए';

  @override
  String get railSpeak => 'कहिए';

  @override
  String get railDone => 'पूरा';

  @override
  String get railNext => 'अगला';

  @override
  String get railLater => 'बाद में';

  @override
  String railSemantic(String label, String state) {
    return '$label, $state';
  }

  @override
  String get youTitle => 'आप';

  @override
  String get yourLight => 'आपकी ज्योति';

  @override
  String get daysOfLightOne => '1 दिन की ज्योति';

  @override
  String daysOfLight(int n) {
    return '$n दिन की ज्योति';
  }

  @override
  String get keptVerses => 'सहेजे श्लोक';

  @override
  String get mokshPoints => 'मोक्ष अंक';

  @override
  String get ekantRow => 'एकांत';

  @override
  String get ekantWhy => 'अपने मन के साथ बैठने का एक शांत कमरा।';

  @override
  String get settingsHead => 'सेटिंग्स';

  @override
  String get practiceRow => 'मेरी साधना';

  @override
  String get practiceRowWhy => 'हम आपको क्या और कब याद दिलाएँ।';

  @override
  String practiceRowValue(int n) {
    return '$n चालू';
  }

  @override
  String get placeRow => 'शहर और परंपरा';

  @override
  String get placeRowWhy => 'आपका सूर्योदय और आपका एकादशी का दिन।';

  @override
  String get soundRow => 'आवाज़ और स्पर्श';

  @override
  String get soundRowWhy => 'हल्की आवाज़ें और हाथ में महसूस होने वाली थपकी।';

  @override
  String get languageRowWhy => 'ऐप के शब्द और हर श्लोक का अर्थ।';

  @override
  String get lookRow => 'रंग-रूप';

  @override
  String get lookRowWhy => 'रात या सुबह की रोशनी।';

  @override
  String get accountRow => 'खाता';

  @override
  String get accountRowWhy => 'आप कौन हैं। यह इसी फ़ोन में रहता है।';

  @override
  String get guest => 'अतिथि';

  @override
  String get signedIn => 'साइन इन है';

  @override
  String get methodNone => 'साइन इन नहीं है';

  @override
  String get methodGuest => 'इस फ़ोन पर अतिथि';

  @override
  String get methodGoogle => 'Google से साइन इन है';

  @override
  String methodPhone(String phone) {
    return '$phone से साइन इन है';
  }

  @override
  String get phoneWord => 'फ़ोन';

  @override
  String get placeSheetWhy =>
      'आपके शहर से हमें पता चलता है कि आपके यहाँ सूरज कब उगता है। पूजा का समय सूरज के साथ चलता है।';

  @override
  String get yourCity => 'आपका शहर';

  @override
  String get whyYourCity => 'आपका शहर क्यों?';

  @override
  String get cityInfo1 => 'हर शहर में सूरज अलग समय पर उगता है।';

  @override
  String get cityInfo2 =>
      'सूर्योदय से चंद्रमा की हर तिथि शुरू होती है। इसलिए आपका शहर हर व्रत और दीये का सही दिन और समय तय करता है।';

  @override
  String get howYouKeepEkadashi => 'आप एकादशी कैसे मनाते हैं';

  @override
  String get soundSheetWhy => 'छोटे संकेत कि ऐप ने आपकी बात सुनी।';

  @override
  String get soundLabel => 'आवाज़';

  @override
  String get soundWhy => 'हल्की घंटियाँ और लकड़ी की थपक।';

  @override
  String get soundInfo1 =>
      'जब आप कोई बटन दबाते हैं, तो हल्की थपक सुनाई देती है।';

  @override
  String get soundInfo2 => 'जब आप कोई कदम पूरा करते हैं, तो छोटी घंटी बजती है।';

  @override
  String get soundInfo3 =>
      'यह हमेशा धीमी और छोटी होती है। आवाज़ कितनी आए, यह आपके फ़ोन का वॉल्यूम तय करता है।';

  @override
  String get hapticsLabel => 'स्पर्श';

  @override
  String get hapticsWhy => 'हाथ में महसूस होने वाली छोटी-सी थपकी।';

  @override
  String get hapticsInfo1 =>
      'स्पर्श का मतलब है कि फ़ोन हल्का-सा हिलता है, जैसे कोई धीरे से खटखटाए।';

  @override
  String get hapticsInfo2 =>
      'जब आप कुछ चुनते हैं या कोई कदम पूरा करते हैं, तब यह महसूस होता है।';

  @override
  String get lookSheetWhy => 'ऐप कैसा दिखे।';

  @override
  String get appearance => 'रंग-रूप';

  @override
  String get appearanceAuto => 'अपने आप';

  @override
  String get appearanceAutoHint =>
      'आज वाला पन्ना सुबह 5 से 10 बजे तक सुबह जैसा उजला हो जाता है।';

  @override
  String get appearanceNight => 'रात';

  @override
  String get appearanceNightHint => 'पूरे दिन वही गर्म अँधेरा।';

  @override
  String get languageSheetWhy =>
      'ऐप के शब्द और हर श्लोक के नीचे दिखने वाला अर्थ।';

  @override
  String get languageEnglishHint => 'ऐप और अर्थ अंग्रेज़ी में।';

  @override
  String get languageHindiHint => 'ऐप और अर्थ हिन्दी में।';

  @override
  String get textSizeSheetWhy => 'वह आकार चुनिए जो आँखों को आसान लगे।';

  @override
  String get accountSheetWhy =>
      'यहाँ आप कौन हैं। आपका सब कुछ इसी फ़ोन में रहता है।';

  @override
  String get whatToCall => 'हम आपको क्या कहकर बुलाएँ?';

  @override
  String get yourName => 'आपका नाम';

  @override
  String get signInToKeep =>
      'फ़ोन बदलने पर भी दीया बचा रहे, इसके लिए साइन इन कीजिए।';

  @override
  String get yourData => 'आपकी जानकारी';

  @override
  String get whatStaysTitle => 'आपके पास क्या रहता है';

  @override
  String get dataInfo1 =>
      'आपका दीया, आपके अंक और सहेजे हुए श्लोक इसी फ़ोन में रहते हैं।';

  @override
  String get dataInfo2 =>
      'आप जो बोलते हैं, वह कहीं रखा नहीं जाता। सुना जाता है, फिर छोड़ दिया जाता है।';

  @override
  String get dataInfo3 =>
      'साइन इन अभी सिर्फ़ दिखावटी है। कुछ भी इस फ़ोन से बाहर नहीं जाता।';

  @override
  String get dataLine =>
      'आपकी प्रगति इसी फ़ोन में रहती है। आप जो बोलते हैं, वह रखा नहीं जाता।';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get personKrishna => 'श्रीकृष्ण';

  @override
  String get personArjuna => 'अर्जुन';

  @override
  String get personSanjaya => 'संजय';

  @override
  String get personDhritarashtra => 'धृतराष्ट्र';

  @override
  String get yoga1 => 'अर्जुनविषादयोग';

  @override
  String get yoga2 => 'सांख्ययोग';

  @override
  String get yoga3 => 'कर्मयोग';

  @override
  String get yoga4 => 'ज्ञानकर्मसंन्यासयोग';

  @override
  String get yoga5 => 'कर्मसंन्यासयोग';

  @override
  String get yoga6 => 'ध्यानयोग';

  @override
  String get yoga7 => 'ज्ञानविज्ञानयोग';

  @override
  String get yoga8 => 'अक्षरब्रह्मयोग';

  @override
  String get yoga9 => 'राजविद्याराजगुह्ययोग';

  @override
  String get yoga10 => 'विभूतियोग';

  @override
  String get yoga11 => 'विश्वरूपदर्शनयोग';

  @override
  String get yoga12 => 'भक्तियोग';

  @override
  String get yoga13 => 'क्षेत्रक्षेत्रज्ञविभागयोग';

  @override
  String get yoga14 => 'गुणत्रयविभागयोग';

  @override
  String get yoga15 => 'पुरुषोत्तमयोग';

  @override
  String get yoga16 => 'दैवासुरसम्पद्विभागयोग';

  @override
  String get yoga17 => 'श्रद्धात्रयविभागयोग';

  @override
  String get yoga18 => 'मोक्षसंन्यासयोग';

  @override
  String get tagGrief => 'शोक';

  @override
  String get tagLoss => 'बिछड़ने का दुख';

  @override
  String get tagFear => 'डर';

  @override
  String get tagAnxiety => 'चिंता';

  @override
  String get tagAnger => 'गुस्सा';

  @override
  String get tagEnvy => 'जलन';

  @override
  String get tagComparison => 'तुलना';

  @override
  String get tagPride => 'घमंड';

  @override
  String get tagDesire => 'इच्छा';

  @override
  String get tagGreed => 'लालच';

  @override
  String get tagRestlessness => 'बेचैनी';

  @override
  String get tagDoubt => 'संदेह';

  @override
  String get tagSelfDoubt => 'अपने पर शक';

  @override
  String get tagConfusion => 'उलझन';

  @override
  String get tagLoneliness => 'अकेलापन';

  @override
  String get tagBurnout => 'थकान';

  @override
  String get tagFailure => 'असफलता';

  @override
  String get tagSuccess => 'सफलता';

  @override
  String get tagExamStress => 'परीक्षा का तनाव';

  @override
  String get tagWorkPressure => 'काम का दबाव';

  @override
  String get tagDutyConflict => 'कर्तव्य की उलझन';

  @override
  String get tagProcrastination => 'टालमटोल';

  @override
  String get tagPerfectionism => 'सब कुछ पूरा सही करने की चाह';

  @override
  String get tagFocus => 'ध्यान लगाना';

  @override
  String get tagDiscipline => 'अनुशासन';

  @override
  String get tagHabits => 'आदतें';

  @override
  String get tagPatience => 'धैर्य';

  @override
  String get tagEquanimity => 'समभाव';

  @override
  String get tagDetachment => 'लगाव से मुक्ति';

  @override
  String get tagForgiveness => 'क्षमा';

  @override
  String get tagCompassion => 'करुणा';

  @override
  String get tagKindness => 'दया';

  @override
  String get tagGratitude => 'आभार';

  @override
  String get tagHumility => 'विनम्रता';

  @override
  String get tagFaith => 'श्रद्धा';

  @override
  String get tagSurrender => 'समर्पण';

  @override
  String get tagPurpose => 'जीवन का उद्देश्य';

  @override
  String get tagMortality => 'मृत्यु';

  @override
  String get tagChange => 'बदलाव';

  @override
  String get tagSelfWorth => 'अपना मोल';

  @override
  String get tagSpeech => 'वाणी';

  @override
  String get tagContentment => 'संतोष';

  @override
  String get tagPeace => 'शांति';

  @override
  String get tagHope => 'आशा';

  @override
  String get tagLearning => 'सीखना';

  @override
  String get close => 'बंद करें';

  @override
  String get shareLabel => 'साझा कीजिए';

  @override
  String get shareVerse => 'यह श्लोक साझा कीजिए';

  @override
  String gitaRef(String id) {
    return 'गीता $id';
  }

  @override
  String gitaRefCaps(String id) {
    return 'गीता $id';
  }

  @override
  String get listeningCaps => 'सुन रहे हैं';

  @override
  String get hearEndTitle => 'आज के लिए\nइतना काफ़ी है।';

  @override
  String get hearEndSub => 'श्लोक आपकी राह देखेगा।';

  @override
  String get hearNext => 'अगला कदम चलिए';

  @override
  String get hearRest => 'अभी विश्राम कीजिए';

  @override
  String get explainVerse => 'इस श्लोक का अर्थ समझिए';

  @override
  String verseOfTotalCaps(int n, int total) {
    return '$total में से $n';
  }

  @override
  String get keptCaps => 'सहेजा';

  @override
  String get holdToListen => 'सुनने के लिए दबाए रखिए';

  @override
  String verseSemantic(String id, String sanskrit, String meaning) {
    return 'श्लोक $id। $sanskrit। $meaning';
  }

  @override
  String get verseHint => 'सहेजने के लिए दो बार छुइए। सुनने के लिए दबाए रखिए।';

  @override
  String walkEyebrow(int n) {
    return 'चलिए  ·  2 में से कदम $n';
  }

  @override
  String speakerSaysTo(String speaker, String listener) {
    return '$speaker $listener से कहते हैं:';
  }

  @override
  String speakerSays(String speaker) {
    return '$speaker कहते हैं:';
  }

  @override
  String get chantSemantic =>
      'साथ में पाठ कीजिए। घेरे को दबाए रखिए। पूरा पाठ करने के लिए दो बार छुइए।';

  @override
  String get releaseToPause => 'रुकने के लिए छोड़ दीजिए';

  @override
  String get holdToChant => 'दबाए रखिए और श्लोक के साथ पाठ कीजिए';

  @override
  String get meetsHead => 'आज यह आपसे कहाँ मिलता है?';

  @override
  String get meetsLine1 => 'एक काम जिसे शुरू करने में डर लगता है';

  @override
  String get meetsLine2 => 'एक नतीजा जो मेरे बस में नहीं है';

  @override
  String get meetsLine3 => 'लोग क्या सोचेंगे';

  @override
  String get thisOne => 'यही';

  @override
  String get stepWalkedCaps => 'कदम पूरा हुआ';

  @override
  String get lampIsLit => 'दीया जल गया।';

  @override
  String get mokshPointsCaps => 'मोक्ष अंक';

  @override
  String dayAndLamps(int day, int lit) {
    String _temp0 = intl.Intl.pluralLogic(
      lit,
      locale: localeName,
      other: '$lit दीये',
      one: '1 दीया',
    );
    return 'दिन $day  ·  इस हफ़्ते $_temp0';
  }

  @override
  String get shareStreak => 'अपनी ज्योति साझा कीजिए';

  @override
  String get checkpointCaps => 'पड़ाव';

  @override
  String get finishVerseTitle => 'श्लोक पूरा कीजिए';

  @override
  String get skipForToday => 'आज के लिए छोड़िए';

  @override
  String get finishedVerse => 'आपने श्लोक पूरा कर लिया।';

  @override
  String get sayTheLine => 'दूसरी पंक्ति बोलिए, या उसे छुइए।';

  @override
  String hiddenLineSemantic(int n, int total) {
    return 'छिपी पंक्ति, $total में से $n शब्द दिखे हैं। अगला शब्द देखने के लिए दो बार छुइए।';
  }

  @override
  String get stopListening => 'सुनना रोकिए';

  @override
  String get speakSecondLine => 'दूसरी पंक्ति बोलिए';

  @override
  String get tapToSpeakCaps => 'बोलने के लिए छुइए';

  @override
  String get shareThisLight => 'यह ज्योति साझा कीजिए';

  @override
  String get daysUnbroken => 'दिन, बिना रुके।';

  @override
  String get msWeek => 'एक सप्ताह की ज्योति';

  @override
  String get msMonth => 'एक महीने की ज्योति';

  @override
  String get msHundred => 'सौ दीये';

  @override
  String get msYear => 'एक साल की ज्योति';

  @override
  String get msDays => 'दिनों की ज्योति';

  @override
  String get msLine7 => 'अभ्यास करते रहिए,\nमन धीरे-धीरे स्थिर होता है।';

  @override
  String get msLine30 => 'जब-जब मन भटके,\nउसे प्यार से लौटा लाइए।';

  @override
  String get msLine100 =>
      'सफलता और असफलता में एक-सा रहिए।\nइसी समभाव को योग कहते हैं।';

  @override
  String get msLine365 => 'आप जो भी करें,\nउसे अर्पण मानकर कीजिए।';

  @override
  String keptCount(int n) {
    return '$n सहेजे';
  }

  @override
  String get nothingKept => 'अभी कुछ सहेजा नहीं है।';

  @override
  String get keptEmptyLine => 'किसी श्लोक को यहाँ रखने के लिए उसे दो बार छुइए।';

  @override
  String get goDeeperCaps => 'और गहराई से';

  @override
  String get inEnglish => 'अंग्रेज़ी में';

  @override
  String get inHindi => 'हिन्दी में';

  @override
  String get whoSpeaks => 'कौन बोल रहा है';

  @override
  String whoSpeaksText(String speaker, String listener) {
    return '$speaker, $listener से।';
  }

  @override
  String get whereSits => 'यह कहाँ आता है';

  @override
  String whereSitsText(String ref, String yoga) {
    return '$ref, $yoga।';
  }

  @override
  String verseRef(int chapter, int number) {
    return 'अध्याय $chapter · श्लोक $number';
  }

  @override
  String get whereMeetsLife => 'जीवन से कहाँ मिलता है';

  @override
  String get shareThisLightCaps => 'यह ज्योति साझा कीजिए';

  @override
  String get layoutNight => 'मंदिर की रात';

  @override
  String get layoutIvory => 'सुबह की उजास';

  @override
  String get layoutArch => 'मंदिर का द्वार';

  @override
  String get layoutLampNight => 'दीया, रात';

  @override
  String get layoutLampMorning => 'दीया, सुबह';

  @override
  String cardSemantic(String label) {
    return '$label कार्ड';
  }

  @override
  String get preparing => 'तैयार हो रहा है';

  @override
  String shareCardSemantic(String label) {
    return '$label कार्ड को चित्र के रूप में साझा कीजिए';
  }

  @override
  String shareTextStreak(int n, String app) {
    return 'भगवद्गीता के साथ $n दिन की ज्योति। $app';
  }

  @override
  String shareTextVerse(String id, String meaning, String app) {
    return 'भगवद्गीता $id: $meaning $app';
  }

  @override
  String cardSpeaker(String speaker, String listener, String yoga) {
    return '$speaker ने $listener से कहा  ·  $yoga';
  }

  @override
  String get dayOfLight => 'दिन की ज्योति।';

  @override
  String get daysOfLightDot => 'दिन की ज्योति।';

  @override
  String get fiveAdayThenRest => 'रोज़ पाँच श्लोक, फिर विश्राम।';

  @override
  String get month1 => 'जनवरी';

  @override
  String get month2 => 'फ़रवरी';

  @override
  String get month3 => 'मार्च';

  @override
  String get month4 => 'अप्रैल';

  @override
  String get month5 => 'मई';

  @override
  String get month6 => 'जून';

  @override
  String get month7 => 'जुलाई';

  @override
  String get month8 => 'अगस्त';

  @override
  String get month9 => 'सितंबर';

  @override
  String get month10 => 'अक्टूबर';

  @override
  String get month11 => 'नवंबर';

  @override
  String get month12 => 'दिसंबर';

  @override
  String dayMonth(int day, String month) {
    return '$day $month';
  }

  @override
  String get dayToday => 'आज';

  @override
  String get dayYesterday => 'कल';

  @override
  String get walletPromise =>
      'ये सिर्फ़ बढ़ते हैं।\nयहाँ कुछ भी बिकता नहीं है।';

  @override
  String get howTheyCameCaps => 'ये कैसे मिले';

  @override
  String get firstPoints => 'आपके पहले अंक आज के पाँच श्लोकों के साथ मिलेंगे।';

  @override
  String get reasonHear => 'पाँच श्लोक सुने';

  @override
  String get reasonWalk => 'एक कदम चले';

  @override
  String get reasonSpeak => 'अपने मन की बात कही';

  @override
  String get reasonSankalp => 'संकल्प पर लौटकर देखा';

  @override
  String plusSemantic(int n) {
    return '$n जुड़े';
  }

  @override
  String waitingSemantic(int n) {
    return '$n इंतज़ार में';
  }

  @override
  String get todaysLightCaps => 'आज की ज्योति';

  @override
  String get pointsToday => 'आज के मोक्ष अंक';

  @override
  String get noMorePoints => 'आज और अंक नहीं मिलेंगे। बस शांति।';

  @override
  String get oncePerDay => 'हर कदम के अंक दिन में एक ही बार मिलते हैं।';

  @override
  String get yatraTitle => 'गीता यात्रा';

  @override
  String yatraChapterOf(int n) {
    return '18 में से अध्याय $n';
  }

  @override
  String stoneToday(String yoga, String id) {
    return 'आज: $yoga, $id';
  }

  @override
  String stoneN(int n) {
    return 'कदम $n';
  }

  @override
  String stoneNCheckpoint(int n) {
    return 'कदम $n, पड़ाव';
  }

  @override
  String get todayCaps => 'आज';

  @override
  String yogaAndId(String yoga, String id) {
    return '$yoga · $id';
  }

  @override
  String get intentionGrief =>
      'किसी एक को वह बात बताइए जो आप प्यार से याद करते हैं।';

  @override
  String get intentionLoss =>
      'कोई एक छोटी चीज़ संभालकर रखिए जो आपको अब भी जोड़ती है।';

  @override
  String get intentionFear =>
      'जिससे डर लगता है, उसका पहला छोटा हिस्सा कर लीजिए।';

  @override
  String get intentionAnxiety =>
      'एक काम पूरे मन से कीजिए, फिर नतीजा छोड़ दीजिए।';

  @override
  String get intentionAnger => 'आज जवाब देने से पहले एक साँस रुक जाइए।';

  @override
  String get intentionEnvy => 'किसी और के बारे में एक सच्ची, अच्छी बात कहिए।';

  @override
  String get intentionComparison => 'तुलना किए बिना, अपनी एक अच्छी बात देखिए।';

  @override
  String get intentionPride => 'आज किसी एक से उसकी सलाह पूछिए।';

  @override
  String get intentionDesire => 'एक चाहत को बिना कुछ किए गुज़र जाने दीजिए।';

  @override
  String get intentionGreed => 'बिना गिने कोई एक चीज़ किसी को दे दीजिए।';

  @override
  String get intentionRestlessness => 'फ़ोन उठाने से पहले दो मिनट शांत बैठिए।';

  @override
  String get intentionDoubt => 'सारे जवाब मिलने से पहले एक कदम बढ़ाइए।';

  @override
  String get intentionSelfDoubt =>
      'जो एक छोटा काम करने को कहा था, उसे पूरा कीजिए।';

  @override
  String get intentionConfusion => 'आज जो एक चुनाव ज़रूरी है, उसे लिख लीजिए।';

  @override
  String get intentionLoneliness => 'जिसकी याद आती है, उसे एक संदेश भेजिए।';

  @override
  String get intentionBurnout => 'बिना झिझक दस मिनट आराम कीजिए।';

  @override
  String get intentionFailure => 'वही काम एक बार फिर कीजिए, थोड़ा छोटा करके।';

  @override
  String get intentionSuccess =>
      'जिसने यहाँ तक पहुँचने में मदद की, उस एक को धन्यवाद कहिए।';

  @override
  String get intentionExamStress =>
      'एक विषय पूरे मन से पढ़िए, फिर किताब बंद कर दीजिए।';

  @override
  String get intentionWorkPressure =>
      'एक काम पूरे मन से कीजिए, नतीजे को देखे बिना।';

  @override
  String get intentionDutyConflict =>
      'जो कर्तव्य सामने है, उसे अच्छे से निभाइए।';

  @override
  String get intentionProcrastination =>
      'काम को बस पाँच मिनट के लिए शुरू कीजिए।';

  @override
  String get intentionPerfectionism =>
      'एक काम पूरा कीजिए और उसे काफ़ी मान लीजिए।';

  @override
  String get intentionFocus => 'एक घंटे तक, एक समय में एक ही काम कीजिए।';

  @override
  String get intentionDiscipline => 'अपने से किया एक छोटा वादा निभाइए।';

  @override
  String get intentionHabits =>
      'अच्छी आदत को आज एक बार, रोज़ वाले समय पर कीजिए।';

  @override
  String get intentionPatience => 'किसी एक बात को उसका पूरा समय लेने दीजिए।';

  @override
  String get intentionEquanimity =>
      'एक अच्छे और एक कठिन पल को एक-सी शांति से लीजिए।';

  @override
  String get intentionDetachment =>
      'अपनी पूरी कोशिश कीजिए और नतीजा छोड़ दीजिए।';

  @override
  String get intentionForgiveness => 'आज के लिए कोई एक पुरानी चोट छोड़ दीजिए।';

  @override
  String get intentionCompassion => 'एक चुपचाप भलाई कीजिए, जिसे कोई न देखे।';

  @override
  String get intentionKindness => 'एक चुपचाप भलाई कीजिए, जिसे कोई न देखे।';

  @override
  String get intentionGratitude =>
      'आज रात तीन बातें गिनिए जिनके लिए आप आभारी हैं।';

  @override
  String get intentionHumility => 'आज एक बार बोलने से पहले पूरा सुन लीजिए।';

  @override
  String get intentionFaith => 'अपना काम एक शांत साँस के साथ शुरू कीजिए।';

  @override
  String get intentionSurrender => 'एक चिंता सौंप दीजिए और अपना हिस्सा निभाइए।';

  @override
  String get intentionPurpose =>
      'आज एक ऐसा काम कीजिए जो आपके लिए मायने रखता हो।';

  @override
  String get intentionMortality => 'दस मिनट उस पर लगाइए जो सच में ज़रूरी है।';

  @override
  String get intentionChange => 'एक छोटे बदलाव को बिना रोके अपना लीजिए।';

  @override
  String get intentionSelfWorth =>
      'एक बार अपने से वैसे बात कीजिए जैसे कोई दोस्त करता है।';

  @override
  String get intentionSpeech => 'आज वही बोलिए जो सच भी हो और भला भी।';

  @override
  String get intentionContentment =>
      'एक सीधी-सी चीज़ का आनंद लीजिए, और ज़्यादा की चाह किए बिना।';

  @override
  String get intentionPeace => 'सोने से दस मिनट पहले फ़ोन रख दीजिए।';

  @override
  String get intentionHope => 'आज रात कल के लिए एक छोटा काम कर लीजिए।';

  @override
  String get intentionLearning => 'एक श्लोक फिर से, धीरे-धीरे पढ़िए।';

  @override
  String get intentionDefault =>
      'एक काम पूरे मन से कीजिए, फिर नतीजा छोड़ दीजिए।';

  @override
  String get wasAfraid => 'जब वे डरे हुए थे';

  @override
  String get wasGrieving => 'जब वे शोक में थे';

  @override
  String get wasLost => 'जब वे समझ नहीं पा रहे थे कि क्या करें';

  @override
  String get wasDoubtful => 'जब उनके मन में संदेह था';

  @override
  String get wasTorn => 'जब वे अपने कर्तव्य को लेकर दुविधा में थे';

  @override
  String get wasHeartLost => 'जब उनका मन टूट गया था';

  @override
  String toldPlain(String speaker, String listener) {
    return '$speaker ने $listener से कहा:';
  }

  @override
  String toldWas(String speaker, String listener, String was) {
    return '$speaker ने $listener से कहा, $was:';
  }

  @override
  String get mannCaps => 'मन दर्पण';

  @override
  String get mannAnswerTop => 'एक श्लोक ने आपकी बात सुनी';

  @override
  String get mannAskTonight => 'आज रात आपका मन\nकैसा है?';

  @override
  String get mannAskToday => 'आज आपका मन\nकैसा है?';

  @override
  String get mannTapSpeak => 'छुइए, और जितनी देर चाहें बोलिए।';

  @override
  String get typeInstead => 'लिखकर बताइए';

  @override
  String get mannListening => 'सुन रहे हैं।';

  @override
  String get mannSpeakPrivate => 'बोलिए। इसे सिर्फ़ आप सुनेंगे।';

  @override
  String get done => 'हो गया';

  @override
  String get mannTypingTitle => 'कुछ शब्दों में बताइए,\nमन में क्या है?';

  @override
  String get hearYourself => 'पहले अपनी आवाज़ सुनिए';

  @override
  String get mannHint => 'कल मेरा इंटरव्यू है और मन बार-बार उसी में उलझा है...';

  @override
  String get mannStays =>
      'यह इसी फ़ोन में रहता है। कुछ भी कहीं भेजा नहीं जाता।';

  @override
  String get letVerseAnswer => 'श्लोक को उत्तर देने दीजिए';

  @override
  String intentTonight(String text) {
    return 'आज रात: $text';
  }

  @override
  String intentToday(String text) {
    return 'आज: $text';
  }

  @override
  String get sealAsSankalp => 'इसे अपना संकल्प बनाइए';

  @override
  String get notToday => 'आज नहीं';

  @override
  String get mannOrbSemantic => 'बोलिए। शुरू करने के लिए छुइए।';

  @override
  String get sealIt => 'संकल्प पक्का कीजिए';

  @override
  String get sealedTitle => 'संकल्प हो गया।';

  @override
  String get lookBackTomorrow => 'कल इस पर लौटकर देखिए।';

  @override
  String get sealSankalpCaps => 'संकल्प लीजिए';

  @override
  String get oneSmallIntention => 'एक छोटा-सा इरादा।';

  @override
  String fromGitaChange(String id) {
    return 'गीता $id से। चाहें तो कोई शब्द बदल लीजिए।';
  }

  @override
  String get sealSankalpSemantic => 'इस संकल्प को पक्का कीजिए';

  @override
  String get keptIt => 'मैंने निभाया';

  @override
  String get letItGo => 'मैंने छोड़ दिया';

  @override
  String get replyKept => 'निभाया। ऐसे ही आदत बनती है।';

  @override
  String get replyLetGo => 'छोड़ दिया। आज नई शुरुआत है।';

  @override
  String get yourSankalpCaps => 'आपका संकल्प';

  @override
  String get festival1 => 'बसंत पंचमी';

  @override
  String get festival2 => 'महाशिवरात्रि';

  @override
  String get festival3 => 'होलिका दहन';

  @override
  String get festival4 => 'उगादि और गुड़ी पड़वा';

  @override
  String get festival5 => 'राम नवमी';

  @override
  String get festival6 => 'हनुमान जयंती';

  @override
  String get festival7 => 'अक्षय तृतीया';

  @override
  String get festival8 => 'रथ यात्रा';

  @override
  String get festival9 => 'गुरु पूर्णिमा';

  @override
  String get festival10 => 'रक्षा बंधन';

  @override
  String get festival11 => 'जन्माष्टमी';

  @override
  String get festival12 => 'गणेश चतुर्थी';

  @override
  String get festival13 => 'राधा अष्टमी';

  @override
  String get festival14 => 'अनंत चतुर्दशी';

  @override
  String get festival15 => 'नवरात्रि आरंभ';

  @override
  String get festival16 => 'दुर्गा अष्टमी';

  @override
  String get festival17 => 'महानवमी';

  @override
  String get festival18 => 'विजयादशमी';

  @override
  String get festival19 => 'शरद पूर्णिमा';

  @override
  String get festival20 => 'करवा चौथ';

  @override
  String get festival21 => 'धनतेरस';

  @override
  String get festival22 => 'नरक चतुर्दशी';

  @override
  String get festival23 => 'दिवाली';

  @override
  String get festival24 => 'गोवर्धन पूजा';

  @override
  String get festival25 => 'भाई दूज';

  @override
  String get festival26 => 'तुलसी विवाह';

  @override
  String get festival27 => 'देव दीपावली';

  @override
  String get festival28 => 'मकर संक्रांति';

  @override
  String get festival29 => 'गीता जयंती';

  @override
  String get festival30 => 'होली';

  @override
  String get festivalFallback => 'त्योहार';

  @override
  String get weekday1 => 'सोमवार';

  @override
  String get weekday2 => 'मंगलवार';

  @override
  String get weekday3 => 'बुधवार';

  @override
  String get weekday4 => 'गुरुवार';

  @override
  String get weekday5 => 'शुक्रवार';

  @override
  String get weekday6 => 'शनिवार';

  @override
  String get weekday7 => 'रविवार';

  @override
  String get weekdayShort1 => 'सोम';

  @override
  String get weekdayShort2 => 'मंगल';

  @override
  String get weekdayShort3 => 'बुध';

  @override
  String get weekdayShort4 => 'गुरु';

  @override
  String get weekdayShort5 => 'शुक्र';

  @override
  String get weekdayShort6 => 'शनि';

  @override
  String get weekdayShort7 => 'रवि';

  @override
  String get dayTomorrow => 'कल';

  @override
  String whenOnDay(String day) {
    return '$day को';
  }

  @override
  String clockAt(String period, String t) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'nightEarly': 'रात $t',
      'morning': 'सुबह $t',
      'noon': 'दोपहर $t',
      'evening': 'शाम $t',
      'night': 'रात $t',
      'other': '$t',
    });
    return '$_temp0';
  }

  @override
  String get ritualDailyGita => 'रोज़ की गीता';

  @override
  String get ritualSandhya => 'सुबह की संध्या';

  @override
  String get ritualDiya => 'शाम का दीया';

  @override
  String get ritualEkadashi => 'एकादशी';

  @override
  String get ritualPurnima => 'पूर्णिमा';

  @override
  String get ritualAmavasya => 'अमावस्या';

  @override
  String get ritualPradosh => 'प्रदोष';

  @override
  String get ritualSankashti => 'संकष्टी';

  @override
  String get ritualFestivals => 'त्योहार';

  @override
  String get meaningDailyGita => 'गीता के पाँच श्लोक, आपके चुने समय पर।';

  @override
  String get meaningSandhya =>
      'सूरज उगते समय उसे प्रणाम करने के लिए एक शांत पल।';

  @override
  String get meaningDiya => 'दिन ढलते समय दीया जलाने की एक कोमल याद।';

  @override
  String get meaningEkadashi =>
      'एकादशी चंद्रमा की ग्यारहवीं तिथि है। बहुत से लोग इस दिन व्रत रखते हैं। हम यह भी बताएँगे कि व्रत कब खोलना है। इसे पारण कहते हैं।';

  @override
  String get meaningPurnima => 'पूर्णिमा वह रात है जब चाँद पूरा गोल होता है।';

  @override
  String get meaningAmavasya =>
      'अमावस्या वह रात है जब चाँद नहीं दिखता। अपने पूर्वजों को याद करने का समय।';

  @override
  String get meaningPradosh =>
      'प्रदोष चंद्रमा की तेरहवीं तिथि की संध्या है, जो शिव के लिए रखी जाती है।';

  @override
  String get meaningSankashti =>
      'संकष्टी गणेश जी का व्रत है। यह चाँद निकलने पर खुलता है।';

  @override
  String get meaningFestivals =>
      'दिवाली और होली जैसे बड़े दिन, आपके शहर की सही तारीख़ पर।';

  @override
  String get deityNone => 'कोई नहीं';

  @override
  String get deityShiva => 'शिव, सोमवार';

  @override
  String get deityHanuman => 'हनुमान, मंगलवार';

  @override
  String get deityVishnu => 'विष्णु या गुरु, गुरुवार';

  @override
  String get deityShani => 'शनि, शनिवार';

  @override
  String get deityMeaningNone => 'अभी कोई ख़ास दिन नहीं।';

  @override
  String get deityMeaningShiva => 'सोमवार शिव का दिन है। सूर्यास्त पर एक दीया।';

  @override
  String get deityMeaningHanuman =>
      'मंगलवार हनुमान जी का दिन है। सुबह हनुमान चालीसा।';

  @override
  String get deityMeaningVishnu =>
      'गुरुवार विष्णु का दिन है, जो गुरुओं के भी गुरु हैं।';

  @override
  String get deityMeaningShani =>
      'शनिवार शनि का दिन है। सूर्यास्त पर एक शांत दीया।';

  @override
  String get noteGita => 'पाँच श्लोक तैयार हैं। फ़ुर्सत से सुनिए।';

  @override
  String noteSandhya(String time) {
    return 'सूर्योदय $time पर। चाहें तो सुबह की संध्या के लिए एक शांत पल।';
  }

  @override
  String noteDiya(String time) {
    return 'सूर्यास्त $time पर। जब मन हो, शाम का दीया जला लीजिए।';
  }

  @override
  String noteShiva(String time) {
    return 'सोमवार। चाहें तो सूर्यास्त के समय, $time पर, शिव के लिए दीया जलाइए।';
  }

  @override
  String get noteHanuman => 'मंगलवार। चाहें तो आज सुबह हनुमान चालीसा पढ़िए।';

  @override
  String noteVishnu(String time) {
    return 'गुरुवार। चाहें तो सूर्यास्त के समय, $time पर, विष्णु के लिए दीया जलाइए।';
  }

  @override
  String noteShani(String time) {
    return 'शनिवार। चाहें तो सूर्यास्त के समय, $time पर, एक शांत दीया जलाइए।';
  }

  @override
  String get notePurnima =>
      'आज रात पूर्णिमा है। पूरा चाँद सूर्यास्त के आसपास निकलता है।';

  @override
  String get noteAmavasya =>
      'आज अमावस्या है। चाहें तो अपने पूर्वजों के लिए एक दीया जलाइए।';

  @override
  String notePradosh(String range) {
    return 'आज प्रदोष है। प्रदोष काल $range।';
  }

  @override
  String noteSankashti(String time) {
    return 'आज रात संकष्टी है। चंद्रोदय $time पर।';
  }

  @override
  String noteFestival(String name) {
    return 'आज $name है। आपका दिन शांत और उजला रहे।';
  }

  @override
  String noteEkadashi(String rule, String when, String range) {
    return 'एकादशी$rule सूर्योदय से शुरू होती है। व्रत $when $range के बीच खोलिए।';
  }

  @override
  String noteParana(String range) {
    return 'पारण का समय: $range। व्रत आराम से खोलिए।';
  }

  @override
  String labelEkadashiRule(String rule) {
    return 'एकादशी ($rule)';
  }

  @override
  String labelParana(String range) {
    return 'पारण $range';
  }

  @override
  String labelPradosh(String range) {
    return 'प्रदोष $range';
  }

  @override
  String ruleSuffix(String rule) {
    return ' ($rule)';
  }

  @override
  String get notifChannel => 'साधना की याद';

  @override
  String get notifChannelDesc => 'आपकी चुनी हुई साधना के लिए शांत सूचनाएँ।';

  @override
  String get practiceTitle => 'आपकी साधना';

  @override
  String get practiceRebuild => 'मेरी साधना फिर से बनाइए';

  @override
  String get allReminders => 'सारे याद दिलाने वाले संदेश';

  @override
  String nextNote(String when) {
    return 'अगला: $when';
  }

  @override
  String get changeHour => 'समय बदलिए';

  @override
  String get turnOff => 'इसे बंद कीजिए';

  @override
  String get practiceIntro =>
      'हम आपको क्या और कब याद दिलाते हैं। किसी पर छुइए, उसका मतलब दिखेगा।';

  @override
  String get nothingOn => 'अभी कुछ चालू नहीं है।';

  @override
  String get allRemindersWhy =>
      'हर स्विच अलग-अलग। जब आपको ठीक पता हो कि क्या चाहिए।';

  @override
  String get hourSheetWhy => 'इस समय आपके पाँच श्लोक आपकी राह देखेंगे।';

  @override
  String get verseHour => 'श्लोक का समय';

  @override
  String get weekdayLamp => 'हफ़्ते का एक दीया';

  @override
  String get savePractice => 'मेरी साधना सहेजिए';

  @override
  String itemAtTime(String label, String time) {
    return '$label, $time';
  }

  @override
  String ritualSemantic(String label, String meaning) {
    return '$label। $meaning';
  }

  @override
  String get traditionCaps => 'स्मार्त और वैष्णव';

  @override
  String get traditionExplTitle => 'एकादशी रखने के दो तरीके';

  @override
  String get traditionTithi =>
      'चंद्रमा के अपने दिन होते हैं। हर एक को तिथि कहते हैं। तिथि आधी रात को शुरू नहीं होती। वह किसी भी घड़ी शुरू हो सकती है।';

  @override
  String get traditionEkadashi =>
      'एकादशी ग्यारहवीं तिथि है। उससे ठीक पहले दशमी, यानी दसवीं तिथि, आती है।';

  @override
  String get traditionSmartaRule =>
      'जिस दिन सूर्योदय के समय एकादशी हो, उसी दिन व्रत रखें।';

  @override
  String get traditionVaishnavaRule =>
      'एकादशी भोर से ही शुद्ध होनी चाहिए, यानी सूर्योदय से लगभग डेढ़ घंटे पहले से। अगर उस समय दशमी बाकी हो, तो अगले दिन व्रत रखें।';

  @override
  String get traditionSame => 'ज़्यादातर महीनों में दोनों एक ही दिन पड़ते हैं।';

  @override
  String get traditionUnsureLine =>
      'पक्का पता नहीं? जैसा आपके घर में होता है, वैसा ही कीजिए। इसे बाद में बदल सकते हैं।';

  @override
  String get traditionRare =>
      'कुछ महीनों में चंद्रमा तेज़ चलता है और दूसरे नियम तय करते हैं। जहाँ हमने जाँचा, हमारी तारीख़ें दृक् पंचांग से मिलती हैं।';

  @override
  String get gotIt => 'ठीक है';

  @override
  String get timelineSemantic =>
      'दो सूर्योदय। पहले दिन भोर के बाद दशमी समाप्त होती है। स्मार्त दीया पहले दिन रहता है। वैष्णव दीया दूसरे दिन चला जाता है।';

  @override
  String get tlDashami => 'दशमी';

  @override
  String get tlEkadashi => 'एकादशी';

  @override
  String get tlDvadashi => 'द्वादशी';

  @override
  String get tlDay1 => 'दिन 1';

  @override
  String get tlDay2 => 'दिन 2';

  @override
  String get tlDawn => 'भोर';

  @override
  String get tlSmarta => 'स्मार्त';

  @override
  String get tlVaishnava => 'वैष्णव';

  @override
  String clockRange(String same, String aBare, String aFull, String bFull) {
    return '$aFull से $bFull';
  }

  @override
  String nameLead(String name) {
    return '$name:  ';
  }

  @override
  String get crisisTitle => 'आपको यह अकेले नहीं उठाना है।';

  @override
  String get crisisBody =>
      'आपने जो बताया, वह बहुत भारी लगता है। एक प्रशिक्षित व्यक्ति अभी आपकी मदद कर सकता है।';

  @override
  String get crisisCall => 'टेली-मानस 14416 पर कॉल कीजिए';

  @override
  String get crisisDialFallback =>
      'अपने फ़ोन से 14416 या 1-800-891-4416 मिलाइए।';

  @override
  String get crisisFree =>
      'मुफ़्त, किसी भी समय, कई भाषाओं में। यह नंबर भी है: 1-800-891-4416।';

  @override
  String get crisisEmergency => 'अभी ख़तरे में हैं तो 112 पर कॉल कीजिए';

  @override
  String get crisisEmergencyFallback => 'अपने फ़ोन से 112 मिलाइए।';

  @override
  String get crisisMessage => 'किसी भरोसेमंद व्यक्ति को संदेश भेजिए';

  @override
  String get crisisSmsBody =>
      'क्या आप मुझे फ़ोन कर सकते हैं? मेरा समय बहुत कठिन चल रहा है।';

  @override
  String crisisSmsFallback(String text) {
    return 'किसी भरोसेमंद को यह भेजिए: “$text”';
  }

  @override
  String get crisisBreathe => 'यहीं रुकिए और साँस लीजिए';

  @override
  String get crisisNothingKept =>
      'आपने जो लिखा, वह रखा नहीं गया। कोई अंक नहीं, कोई रिकॉर्ड नहीं।';

  @override
  String get breatheSemantic =>
      '4 सेकंड साँस भीतर लीजिए, और 6 सेकंड में बाहर छोड़िए।';

  @override
  String get breatheStill => '4 में भीतर। 6 में बाहर।';

  @override
  String get breatheIn => 'साँस भीतर लीजिए';

  @override
  String get breatheOut => 'साँस बाहर छोड़िए';

  @override
  String get authShortNumber => 'यह नंबर बहुत छोटा लग रहा है।';

  @override
  String get authShortCode => 'कोड में छह अंक होते हैं।';

  @override
  String get authSignInFirst => 'पहले साइन इन कीजिए।';

  @override
  String get friendName => 'मित्र';

  @override
  String get ekWrite => 'लिखिए';

  @override
  String get ekSpeak => 'बोलिए';

  @override
  String get ekDoorPrivacy =>
      'आपके शब्द इसी फ़ोन में रहते हैं। बात पूरी होने पर उन्हें मिट जाने दीजिए, या सहेज लीजिए।';

  @override
  String get ekDoorWaiting => 'आपकी पिछली बातचीत अभी यहीं है।';

  @override
  String get ekSend => 'भेजिए';

  @override
  String get ekWriteHint => 'यहाँ लिखिए';

  @override
  String get ekAnswerHint => 'जवाब दीजिए, या और कुछ कहिए';

  @override
  String get ekYouSaid => 'आपने कहा';

  @override
  String get ekEkantSaid => 'एकांत';

  @override
  String get ekReflecting => 'एकांत सोच रहा है';

  @override
  String get ekCopy => 'कॉपी कीजिए';

  @override
  String get ekCopied => 'कॉपी हो गया';

  @override
  String get ekStudy => 'यह श्लोक पढ़िए';

  @override
  String get ekFailedNote => 'कमरा चुप हो गया। कृपया फिर से कोशिश कीजिए।';

  @override
  String get ekShareFooter => 'एकांत से, DharmaScroll में';

  @override
  String get ekOpen1 => 'काम का बोझ मन पर भारी है।';

  @override
  String get ekOpen2 => 'चिंता रुकती ही नहीं।';

  @override
  String get ekOpen3 => 'आज अकेलापन लग रहा है।';

  @override
  String get ekOpen4 => 'गुस्सा है, और वह जा नहीं रहा।';

  @override
  String get ekConnecting => 'तैयार हो रहे हैं';

  @override
  String get ekIdle => 'तैयार';

  @override
  String get ekListening => 'सुन रहे हैं';

  @override
  String get ekThinking => 'सोच रहे हैं';

  @override
  String get ekSpeaking => 'बोल रहे हैं';

  @override
  String get ekMuted => 'आवाज़ बंद है';

  @override
  String get ekConnectFailed => 'जुड़ नहीं पाए';

  @override
  String get ekMute => 'आवाज़ बंद कीजिए';

  @override
  String get ekUnmute => 'आवाज़ चालू कीजिए';

  @override
  String get ekEnd => 'समाप्त';

  @override
  String get ekSwitchToChat => 'लिखकर बात कीजिए';

  @override
  String get ekHandsFree => 'अपने आप';

  @override
  String get ekPushToTalk => 'दबाकर बोलिए';

  @override
  String get ekHoldToTalk => 'बोलने के लिए दबाए रखिए';

  @override
  String get ekRelease => 'बात पूरी होने पर छोड़ दीजिए';

  @override
  String get ekYou => 'आप';

  @override
  String get ekCaptionsEmpty => 'आप बोलेंगे तो शब्द यहाँ दिखेंगे।';

  @override
  String get ekRetry => 'फिर कोशिश कीजिए';

  @override
  String get ekMicTitle => 'माइक्रोफ़ोन इस्तेमाल करें?';

  @override
  String get ekMicBody =>
      'बात करने के लिए फ़ोन को आपको सुनना होगा। आवाज़ सिर्फ़ तब इस्तेमाल होती है जब यह कमरा खुला हो। आप जैसे बोलते हैं, शब्द यहाँ दिखते जाते हैं।';

  @override
  String get ekMicAllow => 'माइक्रोफ़ोन की अनुमति दीजिए';

  @override
  String get ekMicDenied =>
      'माइक्रोफ़ोन बंद है। आप इसे फ़ोन की सेटिंग में चालू कर सकते हैं, या लिखकर बात कर सकते हैं।';

  @override
  String get ekPrompt => 'आपके मन में क्या है?';

  @override
  String get ekRest => 'अब विश्राम कीजिए';

  @override
  String get ekFade => 'इन्हें मिट जाने दीजिए';

  @override
  String get ekKeep => 'इस फ़ोन में सहेजिए';

  @override
  String get ekReturn => 'लौट आइए';

  @override
  String get ekEnough => 'इस बैठक के लिए इतना काफ़ी है।';

  @override
  String get ekKeepFailed => 'इस फ़ोन में सहेज नहीं पाए। फिर कोशिश कीजिए।';

  @override
  String get ekLeaveRoom => 'कमरे से बाहर जाइए';

  @override
  String get ekLeaveCaps => 'बाहर जाइए';

  @override
  String get ekQuietRoom => 'एक शांत कमरा।';

  @override
  String get ekNoOne =>
      'यहाँ कोई नहीं है। ऐप गीता का एक श्लोक ढूँढता है। सिर्फ़ श्लोक ही गीता के शब्द हैं।';

  @override
  String get ekDanger =>
      'ख़तरे में हैं? 112 पर कॉल कीजिए। टेली-मानस 14416 मुफ़्त है, किसी भी समय।';

  @override
  String ekKeptNotesBtn(int n) {
    return 'सहेजे हुए नोट ($n)';
  }

  @override
  String get ekVerseToCarry => 'साथ ले जाने के लिए एक श्लोक';

  @override
  String get ekYourWords => 'आपके शब्द';

  @override
  String get ekRestNow => 'अब विश्राम कीजिए।';

  @override
  String get ekKeptOnly => 'सिर्फ़ इस फ़ोन में सहेजा गया। श्लोक साथ रहता है।';

  @override
  String get ekGone => 'आपके शब्द मिट गए। श्लोक साथ रहता है।';

  @override
  String ekVerseSemantic(
    String attribution,
    int chapter,
    int number,
    String meaning,
  ) {
    return '$attribution गीता, अध्याय $chapter, श्लोक $number। $meaning';
  }

  @override
  String ekVerseCardSemantic(
    int chapter,
    int number,
    String meaning,
    String study,
  ) {
    return 'गीता, अध्याय $chapter, श्लोक $number। $meaning। $study';
  }

  @override
  String ekGitaStudy(String id, String study) {
    return 'गीता $id। $study';
  }

  @override
  String ekGitaStudyCaps(String id, String study) {
    return 'गीता $id  ·  $study';
  }

  @override
  String get ekKeptNotes => 'सहेजे हुए नोट';

  @override
  String get ekKeptNotesWhy => 'सिर्फ़ इस फ़ोन में, एन्क्रिप्ट करके।';

  @override
  String get ekDelete => 'मिटाइए';

  @override
  String ekNoteHead(String date, String id) {
    return '$date  ·  गीता $id';
  }

  @override
  String get ekVoiceUnavailable =>
      'यहाँ आवाज़ से बोलना नहीं हो पाएगा। लिखकर बात हो सकती है।';

  @override
  String get ekTalkOutLoud => 'एकांत से बोलकर बात कीजिए';

  @override
  String get ekWriteIntro =>
      'जैसा मन में आए, वैसा लिखिए। हिन्दी, अंग्रेज़ी या हिंग्लिश में।';

  @override
  String get ekDictate => 'बोलकर लिखिए';

  @override
  String get exSimpleLabel => 'सरल शब्दों में';

  @override
  String get exSimpleHead => 'इसका मतलब';

  @override
  String get exWordsLabel => 'शब्द-शब्द';

  @override
  String get exWordsHead => 'एक बार में एक शब्द';

  @override
  String get exMomentLabel => 'वह क्षण';

  @override
  String get exMomentHead => 'कुरुक्षेत्र, भोर में';

  @override
  String get exRelatedLabel => 'जुड़े श्लोक';

  @override
  String get exRelatedHead => 'उसी राह पर';

  @override
  String get exMyDayLabel => 'मेरे दिन के लिए';

  @override
  String get exMyDayHead => 'आपकी ओर से एक पंक्ति';

  @override
  String get exDraftNote =>
      'इस ऐप के लिए लिखा गया। प्रारूप, विद्वान की समीक्षा बाकी।';

  @override
  String get exOfflineNote =>
      'AI से लिखे उत्तर जल्द आएँगे। अभी श्लोक आपके फ़ोन से ही उत्तर देता है।';

  @override
  String get exAskHint => 'आज आपके मन में क्या है?';

  @override
  String get exAskLabel => 'दिखाइए';

  @override
  String exBackTo(String id) {
    return 'गीता $id पर लौटिए';
  }

  @override
  String exVerseSemantic(String id, String sanskrit) {
    return 'श्लोक $id। $sanskrit';
  }

  @override
  String get exListen => 'सुनिए';

  @override
  String get exListenHint => 'सुनने के लिए दबाए रखिए';

  @override
  String get exWordsNote =>
      'शब्दों के अर्थ अंग्रेज़ी में हैं। प्रारूप, विद्वान की समीक्षा बाकी।';

  @override
  String exSpeaksTo(String speaker, String listener) {
    return '$speaker $listener से बात करते हैं।';
  }

  @override
  String exChapterHead(int chapter, String yoga) {
    return 'अध्याय $chapter · $yoga';
  }

  @override
  String exOpenGita(String id) {
    return 'गीता $id खोलिए';
  }

  @override
  String get exOfflineCaps => 'ऑफ़लाइन · आपके फ़ोन से';

  @override
  String get exBusy => 'श्लोक को सुन रहे हैं';

  @override
  String get exBySoftware => 'सॉफ़्टवेयर ने श्लोक से लिखा।';

  @override
  String get exFromPhone => 'आपके फ़ोन से। यह कोई गुरु या सलाहकार नहीं है।';

  @override
  String get exStoryOnly =>
      'यह श्लोक कथा का हिस्सा है, आपके दिन के लिए सलाह नहीं। यह दूसरा श्लोक शायद आपके ज़्यादा पास हो।';

  @override
  String exSaid(String speaker, String listener, String situations) {
    return '$speaker ने $listener से यह $situations के पलों के लिए कहा था।';
  }

  @override
  String exListAnd(String rest, String last) {
    return '$rest और $last';
  }

  @override
  String exCarry(String said) {
    return '$said आज इसकी एक पंक्ति अपने साथ रखिए।';
  }

  @override
  String exMeets(String said, String tag) {
    return '$said यह उस $tag से मिलता है जिसके बारे में आपने लिखा। इसे एक बार फिर, धीरे-धीरे पढ़िए।';
  }

  @override
  String exCloser(String said, String tag, String id) {
    return '$said $tag के लिए गीता $id शायद ज़्यादा काम की हो।';
  }

  @override
  String exHold(String said) {
    return '$said अपने दिन को इसके सामने रखिए और देखिए क्या साथ रह जाता है।';
  }

  @override
  String get litLamp => 'एक जला हुआ दीया';

  @override
  String get unlitLamp => 'एक बिना जला दीया';

  @override
  String lampsLitWeek(int n) {
    return 'इस हफ़्ते 7 में से $n दीये जले';
  }

  @override
  String shareCardGita(String id) {
    return 'भगवद्गीता  ·  $id';
  }

  @override
  String listEnd(String text) {
    return '$text।';
  }
}
