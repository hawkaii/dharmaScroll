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
}
