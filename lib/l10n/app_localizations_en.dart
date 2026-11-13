// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get continueLabel => 'Continue';

  @override
  String whatIs(String topic) {
    return 'What is $topic?';
  }

  @override
  String progressOf(int n, int total) {
    return '$n of $total';
  }

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get moreLanguages => 'More languages';

  @override
  String languageSoonSemantic(String name) {
    return '$name, coming soon, not ready yet';
  }

  @override
  String get textSizeRow => 'Text size';

  @override
  String get textSizeEyebrow => 'TEXT SIZE';

  @override
  String get textSizeTitle => 'How big should\nthe words be?';

  @override
  String get textSizeWhy =>
      'Pick the size that is easy on your eyes. You can change it later.';

  @override
  String get textSizeNormal => 'Normal';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeExtraLarge => 'Extra large';

  @override
  String get textSizeSample =>
      'The lamp is lit. Five verses are waiting for you.';

  @override
  String get textSizeRowWhy => 'Make the words bigger or smaller.';

  @override
  String get welcomeLine1 => 'A conversation';

  @override
  String get welcomeLine2 => 'on a battlefield.';

  @override
  String get welcomeSub => 'Five thousand years old.\nListen in.';

  @override
  String get welcomeButton => 'Listen';

  @override
  String get eyebrowLight => 'YOUR LIGHT';

  @override
  String get eyebrowCity => 'YOUR CITY';

  @override
  String get eyebrowTradition => 'YOUR TRADITION';

  @override
  String get eyebrowHour => 'YOUR HOUR';

  @override
  String get signInTitle => 'Who is lighting\nthe lamp?';

  @override
  String get cityTitle => 'Where do you\nwatch the sun?';

  @override
  String get traditionTitle => 'How do you\nkeep Ekadashi?';

  @override
  String get reminderTitle => 'When does your\nday begin?';

  @override
  String get finishLabel => 'Light the first lamp';

  @override
  String get whySignIn =>
      'Signing in will keep your lamp and your verses if you change phones. For now, all of it stays on this phone.';

  @override
  String get whyCity =>
      'Your city tells us when the sun rises for you. Prayers follow the sun.';

  @override
  String get whyTradition =>
      'Families keep the Ekadashi fast in two ways. Some months, the days differ.';

  @override
  String get whyHour =>
      'Five verses will wait for you at this hour. Every day, the same quiet time.';

  @override
  String get seeDifference => 'See the difference';

  @override
  String get topicSmartaVaishnava => 'Smarta and Vaishnava';

  @override
  String get traditionSmarta => 'Smarta';

  @override
  String get traditionVaishnava => 'Vaishnava';

  @override
  String get traditionUnsure => 'Not sure';

  @override
  String get hintSmarta => 'Fast on the day Ekadashi meets the sunrise.';

  @override
  String get hintVaishnava => 'Wait for an Ekadashi that is clean from dawn.';

  @override
  String get hintUnsure => 'We show both days when they differ.';

  @override
  String get dragToChangeAm => 'AM  ·  DRAG TO CHANGE';

  @override
  String get dragToChangePm => 'PM  ·  DRAG TO CHANGE';

  @override
  String get reminderTimeLabel => 'Reminder time';

  @override
  String get earlier15 => '15 minutes earlier';

  @override
  String get later15 => '15 minutes later';

  @override
  String get searchCity => 'Search a city';

  @override
  String get signInGoogle => 'Continue with Google';

  @override
  String get signInPhone => 'Continue with phone';

  @override
  String get signInGuest => 'Continue as guest';

  @override
  String get sendCode => 'Send the code';

  @override
  String get verify => 'Verify';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get codeNote => 'We send a six-number code to this phone.';

  @override
  String codeSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get otherWays => 'Other ways to sign in';

  @override
  String get changeNumber => 'Change the number';

  @override
  String get sixNumberCode => 'Six-number code';

  @override
  String practiceEyebrow(int n, int total) {
    return 'YOUR PRACTICE  ·  $n OF $total';
  }

  @override
  String get practiceQ1 => 'Do you keep\na fast?';

  @override
  String get practiceQ2 => 'Which day\nfeels like yours?';

  @override
  String get practiceQ3 => 'Do you light\na lamp at dusk?';

  @override
  String get practiceQ4 => 'A quiet minute\nat sunrise?';

  @override
  String get practiceQ5 => 'The full moon\nand big days?';

  @override
  String get practiceWhy1 =>
      'Ekadashi is the eleventh day of the moon. It comes twice a month. Many people fast on it.';

  @override
  String get practiceWhy2 =>
      'Many homes keep one day of the week for one god. Pick one, or none.';

  @override
  String get practiceWhy3 =>
      'Dusk is when day turns into night. A small lamp then is an old way to say thank you.';

  @override
  String get practiceWhy4 =>
      'Sandhya means the meeting of night and day. One still minute as the sun comes up.';

  @override
  String get practiceWhy5 =>
      'Purnima is the full moon. Amavasya is the night with no moon. Big days like Diwali fall on them.';

  @override
  String get yesEkadashi => 'Yes, on Ekadashi';

  @override
  String get yesEvenings => 'Yes, most evenings';

  @override
  String get yesPlease => 'Yes, please';

  @override
  String get yesTellMe => 'Yes, tell me';

  @override
  String get notNow => 'Not now';

  @override
  String get noDay => 'No day for now';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get godShiva => 'Shiva';

  @override
  String get godHanuman => 'Hanuman';

  @override
  String get godVishnu => 'Vishnu, Guru';

  @override
  String get godShani => 'Shani';

  @override
  String get firstNoteTag => 'YOUR FIRST NOTE';

  @override
  String firstNoteSemantic(String when, String body) {
    return 'Your first note. $when. $body';
  }

  @override
  String get timedToSun => 'Timed to your sun';

  @override
  String get timeFromCity => 'We work out the time from your city.';

  @override
  String get nothingSoon =>
      'Nothing in the next few weeks. We will tell you when it comes.';

  @override
  String get tabToday => 'Today';

  @override
  String get tabYatra => 'Yatra';

  @override
  String get tabYou => 'You';

  @override
  String get todayBegin => 'Begin today\'s ritual';

  @override
  String get todayContinue => 'Continue the ritual';

  @override
  String get todayAgain => 'Light it again';

  @override
  String get todayHearAgain => 'Hear them again';

  @override
  String get todayDoneTitle => 'Today is lit.';

  @override
  String get todayCameBack => 'You came back.';

  @override
  String get todayWalkedTitle => 'The lamp is lit.\nNow, speak your mind.';

  @override
  String get todayHeardTitle => 'Five heard.\nNow take one step\non the path.';

  @override
  String get greetMorning => 'Good morning.';

  @override
  String greetMorningName(String name) {
    return 'Good morning, $name.';
  }

  @override
  String get greetNamaste => 'Namaste.';

  @override
  String greetNamasteName(String name) {
    return 'Namaste, $name.';
  }

  @override
  String get todaySubBack => 'The lamp was still warm.';

  @override
  String get todaySubDone => 'Come back tomorrow.\nThe verses will wait.';

  @override
  String get todaySubWalked => 'A verse will answer.';

  @override
  String get todaySubStart => 'Five verses are waiting.\nThen you may rest.';

  @override
  String topDay(int n) {
    return 'Day $n';
  }

  @override
  String topAdhyaya(int n) {
    return 'Adhyaya $n';
  }

  @override
  String calendarToday(String items) {
    return 'Today in your calendar: $items';
  }

  @override
  String pointsAction(int n) {
    return '$n Moksh Points';
  }

  @override
  String get ekantAction => 'Ekant, a quiet room';

  @override
  String daysKept(int n) {
    return 'Your $n days are kept.';
  }

  @override
  String get earlierDaysKept => 'Your earlier days are kept.';

  @override
  String get railHear => 'Hear';

  @override
  String get railWalk => 'Walk';

  @override
  String get railSpeak => 'Speak';

  @override
  String get railDone => 'done';

  @override
  String get railNext => 'next';

  @override
  String get railLater => 'later';

  @override
  String railSemantic(String label, String state) {
    return '$label, $state';
  }

  @override
  String get youTitle => 'You';

  @override
  String get yourLight => 'Your light';

  @override
  String get daysOfLightOne => '1 day of light';

  @override
  String daysOfLight(int n) {
    return '$n days of light';
  }

  @override
  String get keptVerses => 'Kept verses';

  @override
  String get mokshPoints => 'Moksh Points';

  @override
  String get ekantRow => 'Ekant';

  @override
  String get ekantWhy => 'A quiet room to sit with what you feel.';

  @override
  String get settingsHead => 'SETTINGS';

  @override
  String get practiceRow => 'My practice';

  @override
  String get practiceRowWhy => 'What we remind you of, and when.';

  @override
  String practiceRowValue(int n) {
    return '$n on';
  }

  @override
  String get placeRow => 'City and tradition';

  @override
  String get placeRowWhy => 'Your sunrise, and your Ekadashi day.';

  @override
  String get soundRow => 'Sound and touch';

  @override
  String get soundRowWhy => 'Soft sounds and small taps you can feel.';

  @override
  String get languageRowWhy =>
      'The words in the app, and the meaning of each verse.';

  @override
  String get lookRow => 'Look';

  @override
  String get lookRowWhy => 'Night or morning light.';

  @override
  String get accountRow => 'Account';

  @override
  String get accountRowWhy => 'Who you are. It stays on this phone.';

  @override
  String get guest => 'Guest';

  @override
  String get signedIn => 'Signed in';

  @override
  String get methodNone => 'Not signed in';

  @override
  String get methodGuest => 'Guest on this phone';

  @override
  String get methodGoogle => 'Signed in with Google';

  @override
  String methodPhone(String phone) {
    return 'Signed in with $phone';
  }

  @override
  String get phoneWord => 'phone';

  @override
  String get placeSheetWhy =>
      'Your city tells us when the sun rises for you. Prayers follow the sun.';

  @override
  String get yourCity => 'Your city';

  @override
  String get whyYourCity => 'Why your city?';

  @override
  String get cityInfo1 => 'The sun rises at a different time in every city.';

  @override
  String get cityInfo2 =>
      'Sunrise starts each day of the moon. So your city sets the right day and hour for every fast and lamp.';

  @override
  String get howYouKeepEkadashi => 'How you keep Ekadashi';

  @override
  String get soundSheetWhy => 'Small signs that the app heard you.';

  @override
  String get soundLabel => 'Sound';

  @override
  String get soundWhy => 'Soft bells and wood taps.';

  @override
  String get soundInfo1 => 'When you press a button, you hear a soft tap.';

  @override
  String get soundInfo2 => 'When you finish a step, a small bell rings.';

  @override
  String get soundInfo3 =>
      'It is always quiet and short. Your phone volume still decides.';

  @override
  String get hapticsLabel => 'Touch';

  @override
  String get hapticsWhy => 'A tiny tap you feel in your hand.';

  @override
  String get hapticsInfo1 =>
      'Touch means the phone moves a tiny bit, like a soft knock.';

  @override
  String get hapticsInfo2 =>
      'You feel it when you pick something or finish a step.';

  @override
  String get lookSheetWhy => 'How the app looks.';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceAuto => 'Auto';

  @override
  String get appearanceAutoHint =>
      'Today turns bright like morning, from 5 to 10.';

  @override
  String get appearanceNight => 'Night';

  @override
  String get appearanceNightHint => 'Always the warm dark, all day.';

  @override
  String get languageSheetWhy =>
      'The words in the app, and the meaning shown under each verse.';

  @override
  String get languageEnglishHint => 'The app and the meanings in English.';

  @override
  String get languageHindiHint => 'The app and the meanings in Hindi.';

  @override
  String get textSizeSheetWhy => 'Pick the size that is easy on your eyes.';

  @override
  String get accountSheetWhy =>
      'Who you are here. Your data stays on this phone.';

  @override
  String get whatToCall => 'What should we call you?';

  @override
  String get yourName => 'Your name';

  @override
  String get signInToKeep => 'Sign in to keep your lamp if you change phones.';

  @override
  String get yourData => 'Your data';

  @override
  String get whatStaysTitle => 'What stays with you';

  @override
  String get dataInfo1 =>
      'Your lamp, your points and your kept verses live on this phone.';

  @override
  String get dataInfo2 =>
      'Nothing you speak is stored. It is heard, then let go.';

  @override
  String get dataInfo3 =>
      'Signing in is only pretend for now. Nothing leaves this phone.';

  @override
  String get dataLine =>
      'Your progress lives on this phone. Nothing you speak is stored.';

  @override
  String get signOut => 'Sign out';
}
