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

  @override
  String get personKrishna => 'Krishna';

  @override
  String get personArjuna => 'Arjuna';

  @override
  String get personSanjaya => 'Sanjaya';

  @override
  String get personDhritarashtra => 'Dhritarashtra';

  @override
  String get yoga1 => 'Arjuna Vishada Yoga';

  @override
  String get yoga2 => 'Sankhya Yoga';

  @override
  String get yoga3 => 'Karma Yoga';

  @override
  String get yoga4 => 'Jnana Karma Sannyasa Yoga';

  @override
  String get yoga5 => 'Karma Sannyasa Yoga';

  @override
  String get yoga6 => 'Dhyana Yoga';

  @override
  String get yoga7 => 'Jnana Vijnana Yoga';

  @override
  String get yoga8 => 'Akshara Brahma Yoga';

  @override
  String get yoga9 => 'Raja Vidya Raja Guhya Yoga';

  @override
  String get yoga10 => 'Vibhuti Yoga';

  @override
  String get yoga11 => 'Vishvarupa Darshana Yoga';

  @override
  String get yoga12 => 'Bhakti Yoga';

  @override
  String get yoga13 => 'Kshetra Kshetrajna Vibhaga Yoga';

  @override
  String get yoga14 => 'Gunatraya Vibhaga Yoga';

  @override
  String get yoga15 => 'Purushottama Yoga';

  @override
  String get yoga16 => 'Daivasura Sampad Vibhaga Yoga';

  @override
  String get yoga17 => 'Shraddhatraya Vibhaga Yoga';

  @override
  String get yoga18 => 'Moksha Sannyasa Yoga';

  @override
  String get tagGrief => 'grief';

  @override
  String get tagLoss => 'loss';

  @override
  String get tagFear => 'fear';

  @override
  String get tagAnxiety => 'anxiety';

  @override
  String get tagAnger => 'anger';

  @override
  String get tagEnvy => 'envy';

  @override
  String get tagComparison => 'comparison';

  @override
  String get tagPride => 'pride';

  @override
  String get tagDesire => 'desire';

  @override
  String get tagGreed => 'greed';

  @override
  String get tagRestlessness => 'restlessness';

  @override
  String get tagDoubt => 'doubt';

  @override
  String get tagSelfDoubt => 'self doubt';

  @override
  String get tagConfusion => 'confusion';

  @override
  String get tagLoneliness => 'loneliness';

  @override
  String get tagBurnout => 'burnout';

  @override
  String get tagFailure => 'failure';

  @override
  String get tagSuccess => 'success';

  @override
  String get tagExamStress => 'exam stress';

  @override
  String get tagWorkPressure => 'work pressure';

  @override
  String get tagDutyConflict => 'duty conflict';

  @override
  String get tagProcrastination => 'procrastination';

  @override
  String get tagPerfectionism => 'perfectionism';

  @override
  String get tagFocus => 'focus';

  @override
  String get tagDiscipline => 'discipline';

  @override
  String get tagHabits => 'habits';

  @override
  String get tagPatience => 'patience';

  @override
  String get tagEquanimity => 'equanimity';

  @override
  String get tagDetachment => 'detachment';

  @override
  String get tagForgiveness => 'forgiveness';

  @override
  String get tagCompassion => 'compassion';

  @override
  String get tagKindness => 'kindness';

  @override
  String get tagGratitude => 'gratitude';

  @override
  String get tagHumility => 'humility';

  @override
  String get tagFaith => 'faith';

  @override
  String get tagSurrender => 'surrender';

  @override
  String get tagPurpose => 'purpose';

  @override
  String get tagMortality => 'mortality';

  @override
  String get tagChange => 'change';

  @override
  String get tagSelfWorth => 'self worth';

  @override
  String get tagSpeech => 'speech';

  @override
  String get tagContentment => 'contentment';

  @override
  String get tagPeace => 'peace';

  @override
  String get tagHope => 'hope';

  @override
  String get tagLearning => 'learning';

  @override
  String get close => 'Close';

  @override
  String get shareLabel => 'Share';

  @override
  String get shareVerse => 'Share this verse';

  @override
  String gitaRef(String id) {
    return 'Gita $id';
  }

  @override
  String gitaRefCaps(String id) {
    return 'GITA $id';
  }

  @override
  String get listeningCaps => 'LISTENING';

  @override
  String get hearEndTitle => 'That is enough\nfor today.';

  @override
  String get hearEndSub => 'The verse will wait.';

  @override
  String get hearNext => 'Walk the next step';

  @override
  String get hearRest => 'Rest for now';

  @override
  String get explainVerse => 'Explain this verse';

  @override
  String verseOfTotalCaps(int n, int total) {
    return '$n OF $total';
  }

  @override
  String get keptCaps => 'KEPT';

  @override
  String get holdToListen => 'Hold to listen';

  @override
  String verseSemantic(String id, String sanskrit, String meaning) {
    return 'Verse $id. $sanskrit. $meaning';
  }

  @override
  String get verseHint => 'Double tap to keep. Press and hold to listen.';

  @override
  String walkEyebrow(int n) {
    return 'WALK  ·  STEP $n OF 2';
  }

  @override
  String speakerSaysTo(String speaker, String listener) {
    return '$speaker says to $listener:';
  }

  @override
  String speakerSays(String speaker) {
    return '$speaker says:';
  }

  @override
  String get chantSemantic =>
      'Chant along. Press and hold the ring. Activate to chant it all.';

  @override
  String get releaseToPause => 'RELEASE TO PAUSE';

  @override
  String get holdToChant => 'HOLD AND CHANT WITH THE VERSE';

  @override
  String get meetsHead => 'WHERE DOES THIS MEET YOU TODAY?';

  @override
  String get meetsLine1 => 'A task I am afraid to begin';

  @override
  String get meetsLine2 => 'A result I cannot control';

  @override
  String get meetsLine3 => 'What others will think';

  @override
  String get thisOne => 'This one';

  @override
  String get stepWalkedCaps => 'STEP WALKED';

  @override
  String get lampIsLit => 'The lamp is lit.';

  @override
  String get mokshPointsCaps => 'MOKSH POINTS';

  @override
  String dayAndLamps(int day, int lit) {
    String _temp0 = intl.Intl.pluralLogic(
      lit,
      locale: localeName,
      other: '$lit lamps',
      one: 'one lamp',
    );
    return 'Day $day  ·  $_temp0 this week';
  }

  @override
  String get shareStreak => 'Share your streak';

  @override
  String get checkpointCaps => 'CHECKPOINT';

  @override
  String get finishVerseTitle => 'Finish the verse';

  @override
  String get skipForToday => 'Skip for today';

  @override
  String get finishedVerse => 'You finished the verse.';

  @override
  String get sayTheLine => 'Say the second line, or tap it.';

  @override
  String hiddenLineSemantic(int n, int total) {
    return 'Hidden line, $n of $total words shown. Activate to reveal the next word.';
  }

  @override
  String get stopListening => 'Stop listening';

  @override
  String get speakSecondLine => 'Speak the second line';

  @override
  String get tapToSpeakCaps => 'TAP TO SPEAK';

  @override
  String get shareThisLight => 'Share this light';

  @override
  String get daysUnbroken => 'days, unbroken.';

  @override
  String get msWeek => 'A week of light';

  @override
  String get msMonth => 'A month of light';

  @override
  String get msHundred => 'A hundred lamps';

  @override
  String get msYear => 'A year of light';

  @override
  String get msDays => 'Days of light';

  @override
  String get msLine7 => 'Practise, and the mind\ngrows steady.';

  @override
  String get msLine30 => 'Each time the mind wanders,\nbring it gently back.';

  @override
  String get msLine100 =>
      'Steady in success and failure.\nThat evenness is yoga.';

  @override
  String get msLine365 => 'Whatever you do,\ndo it as an offering.';

  @override
  String keptCount(int n) {
    return '$n kept';
  }

  @override
  String get nothingKept => 'Nothing kept yet.';

  @override
  String get keptEmptyLine => 'Double-tap a verse to keep it here.';

  @override
  String get goDeeperCaps => 'GO DEEPER';

  @override
  String get inEnglish => 'In English';

  @override
  String get inHindi => 'In Hindi';

  @override
  String get whoSpeaks => 'Who speaks';

  @override
  String whoSpeaksText(String speaker, String listener) {
    return '$speaker, to $listener.';
  }

  @override
  String get whereSits => 'Where it sits';

  @override
  String whereSitsText(String ref, String yoga) {
    return '$ref, $yoga.';
  }

  @override
  String verseRef(int chapter, int number) {
    return 'Adhyay $chapter · Shloka $number';
  }

  @override
  String get whereMeetsLife => 'Where it meets life';

  @override
  String get shareThisLightCaps => 'SHARE THIS LIGHT';

  @override
  String get layoutNight => 'Temple night';

  @override
  String get layoutIvory => 'Morning ivory';

  @override
  String get layoutArch => 'Temple arch';

  @override
  String get layoutLampNight => 'Lamp, night';

  @override
  String get layoutLampMorning => 'Lamp, morning';

  @override
  String cardSemantic(String label) {
    return '$label card';
  }

  @override
  String get preparing => 'Preparing';

  @override
  String shareCardSemantic(String label) {
    return 'Share the $label card as an image';
  }

  @override
  String shareTextStreak(int n, String app) {
    return '$n days of light with the Bhagavad Gita. $app';
  }

  @override
  String shareTextVerse(String id, String meaning, String app) {
    return 'Bhagavad Gita $id: $meaning $app';
  }

  @override
  String cardSpeaker(String speaker, String listener, String yoga) {
    return '$speaker to $listener  ·  $yoga';
  }

  @override
  String get dayOfLight => 'day of light.';

  @override
  String get daysOfLightDot => 'days of light.';

  @override
  String get fiveAdayThenRest => 'Five verses a day, then rest.';

  @override
  String get month1 => 'Jan';

  @override
  String get month2 => 'Feb';

  @override
  String get month3 => 'Mar';

  @override
  String get month4 => 'Apr';

  @override
  String get month5 => 'May';

  @override
  String get month6 => 'Jun';

  @override
  String get month7 => 'Jul';

  @override
  String get month8 => 'Aug';

  @override
  String get month9 => 'Sep';

  @override
  String get month10 => 'Oct';

  @override
  String get month11 => 'Nov';

  @override
  String get month12 => 'Dec';

  @override
  String dayMonth(int day, String month) {
    return '$day $month';
  }

  @override
  String get dayToday => 'Today';

  @override
  String get dayYesterday => 'Yesterday';

  @override
  String get walletPromise => 'They only go up.\nNothing here is for sale.';

  @override
  String get howTheyCameCaps => 'HOW THEY CAME';

  @override
  String get firstPoints => 'Your first points come with today\'s five verses.';

  @override
  String get reasonHear => 'Five verses heard';

  @override
  String get reasonWalk => 'One step walked';

  @override
  String get reasonSpeak => 'Spoke your mind';

  @override
  String get reasonSankalp => 'Looked back on a Sankalp';

  @override
  String plusSemantic(int n) {
    return 'plus $n';
  }

  @override
  String waitingSemantic(int n) {
    return '$n waiting';
  }

  @override
  String get todaysLightCaps => 'TODAY\'S LIGHT';

  @override
  String get pointsToday => 'Moksh Points today';

  @override
  String get noMorePoints => 'No more points today. Just peace.';

  @override
  String get oncePerDay => 'Each step gives its points once a day.';

  @override
  String get yatraTitle => 'Gita Yatra';

  @override
  String yatraChapterOf(int n) {
    return 'Adhyaya $n of 18';
  }

  @override
  String stoneToday(String yoga, String id) {
    return 'Today: $yoga, $id';
  }

  @override
  String stoneN(int n) {
    return 'Stone $n';
  }

  @override
  String stoneNCheckpoint(int n) {
    return 'Stone $n, checkpoint';
  }

  @override
  String get todayCaps => 'TODAY';

  @override
  String yogaAndId(String yoga, String id) {
    return '$yoga · $id';
  }

  @override
  String get intentionGrief =>
      'Tell one person something you remember with love.';

  @override
  String get intentionLoss => 'Keep one small thing that still connects you.';

  @override
  String get intentionFear => 'Do the first small part of what you fear.';

  @override
  String get intentionAnxiety => 'Do one task fully, then let the result go.';

  @override
  String get intentionAnger => 'Wait one breath before you answer today.';

  @override
  String get intentionEnvy => 'Say one honest good word about someone else.';

  @override
  String get intentionComparison =>
      'Notice one thing you did well, without comparing.';

  @override
  String get intentionPride => 'Ask one person for their advice today.';

  @override
  String get intentionDesire => 'Let one want pass without acting on it.';

  @override
  String get intentionGreed => 'Give one thing away without counting it.';

  @override
  String get intentionRestlessness =>
      'Sit still for two minutes before your phone.';

  @override
  String get intentionDoubt => 'Take one step before you have every answer.';

  @override
  String get intentionSelfDoubt => 'Finish one small thing you said you would.';

  @override
  String get intentionConfusion =>
      'Write down the one choice that matters today.';

  @override
  String get intentionLoneliness => 'Send one message to someone you miss.';

  @override
  String get intentionBurnout => 'Rest for ten minutes without guilt.';

  @override
  String get intentionFailure => 'Try the thing once more, a little smaller.';

  @override
  String get intentionSuccess => 'Thank one person who helped you get here.';

  @override
  String get intentionExamStress =>
      'Study one topic fully, then close the book.';

  @override
  String get intentionWorkPressure =>
      'Do one task fully, without checking the result.';

  @override
  String get intentionDutyConflict => 'Do the duty in front of you, well.';

  @override
  String get intentionProcrastination =>
      'Start the task for five minutes only.';

  @override
  String get intentionPerfectionism => 'Finish one thing and let it be enough.';

  @override
  String get intentionFocus => 'Do one thing at a time for an hour.';

  @override
  String get intentionDiscipline => 'Keep one small promise to yourself.';

  @override
  String get intentionHabits => 'Do the good habit once, at the same time.';

  @override
  String get intentionPatience => 'Let one thing take the time it takes.';

  @override
  String get intentionEquanimity =>
      'Meet one good and one hard moment the same.';

  @override
  String get intentionDetachment => 'Do your best and leave the result.';

  @override
  String get intentionForgiveness => 'Let go of one old hurt, just for today.';

  @override
  String get intentionCompassion => 'Do one quiet kindness no one will see.';

  @override
  String get intentionKindness => 'Do one quiet kindness no one will see.';

  @override
  String get intentionGratitude =>
      'Name three things you are grateful for tonight.';

  @override
  String get intentionHumility => 'Listen fully before you speak, once today.';

  @override
  String get intentionFaith => 'Begin your work with one quiet breath.';

  @override
  String get intentionSurrender => 'Hand one worry over, and do your part.';

  @override
  String get intentionPurpose => 'Do one thing today that matters to you.';

  @override
  String get intentionMortality => 'Spend ten minutes on what truly matters.';

  @override
  String get intentionChange => 'Welcome one small change without resisting.';

  @override
  String get intentionSelfWorth => 'Speak to yourself once as a friend would.';

  @override
  String get intentionSpeech => 'Say only what is true and kind today.';

  @override
  String get intentionContentment =>
      'Enjoy one simple thing without wanting more.';

  @override
  String get intentionPeace => 'Put the phone down ten minutes before sleep.';

  @override
  String get intentionHope => 'Do one small thing for tomorrow, tonight.';

  @override
  String get intentionLearning => 'Read one verse again, slowly.';

  @override
  String get intentionDefault => 'Do one task fully, then let the result go.';

  @override
  String get wasAfraid => 'who was afraid';

  @override
  String get wasGrieving => 'who was grieving';

  @override
  String get wasLost => 'who did not know what to do';

  @override
  String get wasDoubtful => 'who was full of doubt';

  @override
  String get wasTorn => 'who was torn about his duty';

  @override
  String get wasHeartLost => 'who had lost heart';

  @override
  String toldPlain(String speaker, String listener) {
    return '$speaker told $listener:';
  }

  @override
  String toldWas(String speaker, String listener, String was) {
    return '$speaker told $listener, $was:';
  }

  @override
  String get mannCaps => 'MANN DARPAN';

  @override
  String get mannAnswerTop => 'A verse heard you';

  @override
  String get mannAskTonight => 'How is your mind\ntonight?';

  @override
  String get mannAskToday => 'How is your mind\ntoday?';

  @override
  String get mannTapSpeak => 'Tap, and speak for as long as you need.';

  @override
  String get typeInstead => 'Type instead';

  @override
  String get mannListening => 'Listening.';

  @override
  String get mannSpeakPrivate => 'Speak. Only you will hear this.';

  @override
  String get done => 'Done';

  @override
  String get mannTypingTitle => 'In a few words,\nwhat is on your mind?';

  @override
  String get hearYourself => 'Hear yourself first';

  @override
  String get mannHint => 'I have an interview tomorrow and I keep thinking...';

  @override
  String get mannStays => 'Stays on this phone. Nothing is sent anywhere.';

  @override
  String get letVerseAnswer => 'Let a verse answer';

  @override
  String intentTonight(String text) {
    return 'Tonight: $text';
  }

  @override
  String intentToday(String text) {
    return 'Today: $text';
  }

  @override
  String get sealAsSankalp => 'Seal as my Sankalp';

  @override
  String get notToday => 'Not today';

  @override
  String get mannOrbSemantic => 'Speak. Tap to start.';

  @override
  String get sealIt => 'Seal it';

  @override
  String get sealedTitle => 'Sealed.';

  @override
  String get lookBackTomorrow => 'Look back on it tomorrow.';

  @override
  String get sealSankalpCaps => 'SEAL A SANKALP';

  @override
  String get oneSmallIntention => 'One small intention.';

  @override
  String fromGitaChange(String id) {
    return 'From Gita $id. Change a word if you like.';
  }

  @override
  String get sealSankalpSemantic => 'Seal this Sankalp';

  @override
  String get keptIt => 'I kept it';

  @override
  String get letItGo => 'I let it go';

  @override
  String get replyKept => 'Kept. That is how a habit grows.';

  @override
  String get replyLetGo => 'Let go. Today is a fresh start.';

  @override
  String get yourSankalpCaps => 'YOUR SANKALP';

  @override
  String get festival1 => 'Vasant Panchami';

  @override
  String get festival2 => 'Maha Shivaratri';

  @override
  String get festival3 => 'Holika Dahan';

  @override
  String get festival4 => 'Ugadi and Gudi Padwa';

  @override
  String get festival5 => 'Ram Navami';

  @override
  String get festival6 => 'Hanuman Jayanti';

  @override
  String get festival7 => 'Akshaya Tritiya';

  @override
  String get festival8 => 'Rath Yatra';

  @override
  String get festival9 => 'Guru Purnima';

  @override
  String get festival10 => 'Raksha Bandhan';

  @override
  String get festival11 => 'Janmashtami';

  @override
  String get festival12 => 'Ganesh Chaturthi';

  @override
  String get festival13 => 'Radha Ashtami';

  @override
  String get festival14 => 'Anant Chaturdashi';

  @override
  String get festival15 => 'Navratri begins';

  @override
  String get festival16 => 'Durga Ashtami';

  @override
  String get festival17 => 'Maha Navami';

  @override
  String get festival18 => 'Vijayadashami';

  @override
  String get festival19 => 'Sharad Purnima';

  @override
  String get festival20 => 'Karva Chauth';

  @override
  String get festival21 => 'Dhanteras';

  @override
  String get festival22 => 'Naraka Chaturdashi';

  @override
  String get festival23 => 'Diwali';

  @override
  String get festival24 => 'Govardhan Puja';

  @override
  String get festival25 => 'Bhai Dooj';

  @override
  String get festival26 => 'Tulsi Vivah';

  @override
  String get festival27 => 'Dev Deepawali';

  @override
  String get festival28 => 'Makar Sankranti';

  @override
  String get festival29 => 'Gita Jayanti';

  @override
  String get festival30 => 'Holi';

  @override
  String get festivalFallback => 'Festival';

  @override
  String get weekday1 => 'Monday';

  @override
  String get weekday2 => 'Tuesday';

  @override
  String get weekday3 => 'Wednesday';

  @override
  String get weekday4 => 'Thursday';

  @override
  String get weekday5 => 'Friday';

  @override
  String get weekday6 => 'Saturday';

  @override
  String get weekday7 => 'Sunday';

  @override
  String get weekdayShort1 => 'Mon';

  @override
  String get weekdayShort2 => 'Tue';

  @override
  String get weekdayShort3 => 'Wed';

  @override
  String get weekdayShort4 => 'Thu';

  @override
  String get weekdayShort5 => 'Fri';

  @override
  String get weekdayShort6 => 'Sat';

  @override
  String get weekdayShort7 => 'Sun';

  @override
  String get dayTomorrow => 'Tomorrow';

  @override
  String whenOnDay(String day) {
    return 'on $day';
  }

  @override
  String clockAt(String period, String t) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'nightEarly': '$t am',
      'morning': '$t am',
      'noon': '$t pm',
      'evening': '$t pm',
      'night': '$t pm',
      'other': '$t',
    });
    return '$_temp0';
  }

  @override
  String get ritualDailyGita => 'Daily Gita';

  @override
  String get ritualSandhya => 'Morning sandhya';

  @override
  String get ritualDiya => 'Evening diya';

  @override
  String get ritualEkadashi => 'Ekadashi';

  @override
  String get ritualPurnima => 'Purnima';

  @override
  String get ritualAmavasya => 'Amavasya';

  @override
  String get ritualPradosh => 'Pradosh';

  @override
  String get ritualSankashti => 'Sankashti';

  @override
  String get ritualFestivals => 'Festivals';

  @override
  String get meaningDailyGita =>
      'Five verses from the Gita, at the hour you chose.';

  @override
  String get meaningSandhya => 'A quiet minute to greet the sun as it rises.';

  @override
  String get meaningDiya => 'A soft reminder to light a lamp as the day ends.';

  @override
  String get meaningEkadashi =>
      'Ekadashi is the eleventh day of the moon. Many people fast. We also tell you when to eat again. That is called parana.';

  @override
  String get meaningPurnima =>
      'Purnima is the night the moon is full and round.';

  @override
  String get meaningAmavasya =>
      'Amavasya is the night with no moon. A time to remember family who came before.';

  @override
  String get meaningPradosh =>
      'Pradosh is dusk on the thirteenth day of the moon, kept for Shiva.';

  @override
  String get meaningSankashti =>
      'Sankashti is a fast for Ganesha. It ends when the moon rises.';

  @override
  String get meaningFestivals =>
      'Big days like Diwali and Holi, on the right date for your city.';

  @override
  String get deityNone => 'None';

  @override
  String get deityShiva => 'Shiva, Monday';

  @override
  String get deityHanuman => 'Hanuman, Tuesday';

  @override
  String get deityVishnu => 'Vishnu or Guru, Thursday';

  @override
  String get deityShani => 'Shani, Saturday';

  @override
  String get deityMeaningNone => 'No special day for now.';

  @override
  String get deityMeaningShiva => 'Monday is for Shiva. A lamp at sunset.';

  @override
  String get deityMeaningHanuman =>
      'Tuesday is for Hanuman. The Chalisa in the morning.';

  @override
  String get deityMeaningVishnu =>
      'Thursday is for Vishnu, the teacher of teachers.';

  @override
  String get deityMeaningShani =>
      'Saturday is for Shani. A quiet lamp at sunset.';

  @override
  String get noteGita => 'Five verses are ready. Take your time.';

  @override
  String noteSandhya(String time) {
    return 'Sunrise at $time. A quiet minute for the morning sandhya, if you like.';
  }

  @override
  String noteDiya(String time) {
    return 'Sunset at $time. The evening lamp, whenever you are ready.';
  }

  @override
  String noteShiva(String time) {
    return 'Monday. A lamp for Shiva at sunset, $time, if you like.';
  }

  @override
  String get noteHanuman => 'Tuesday. The Chalisa this morning, if you like.';

  @override
  String noteVishnu(String time) {
    return 'Thursday. A lamp for Vishnu at sunset, $time, if you like.';
  }

  @override
  String noteShani(String time) {
    return 'Saturday. A quiet lamp at sunset, $time, if you like.';
  }

  @override
  String get notePurnima => 'Purnima tonight. The full moon rises near sunset.';

  @override
  String get noteAmavasya =>
      'Amavasya today. A lamp for those who came before, if you like.';

  @override
  String notePradosh(String range) {
    return 'Pradosh today. Pradosh kaal $range.';
  }

  @override
  String noteSankashti(String time) {
    return 'Sankashti tonight. Moonrise $time.';
  }

  @override
  String noteFestival(String name) {
    return '$name is today. A quiet, bright day to you.';
  }

  @override
  String noteEkadashi(String rule, String when, String range) {
    return 'Ekadashi$rule begins at sunrise. Break the fast $when $range.';
  }

  @override
  String noteParana(String range) {
    return 'Parana window: $range. Break the fast gently.';
  }

  @override
  String labelEkadashiRule(String rule) {
    return 'Ekadashi ($rule)';
  }

  @override
  String labelParana(String range) {
    return 'Parana $range';
  }

  @override
  String labelPradosh(String range) {
    return 'Pradosh $range';
  }

  @override
  String ruleSuffix(String rule) {
    return ' ($rule)';
  }

  @override
  String get notifChannel => 'Ritual reminders';

  @override
  String get notifChannelDesc => 'Quiet reminders for the rituals you chose.';

  @override
  String get practiceTitle => 'Your practice';

  @override
  String get practiceRebuild => 'Build my practice again';

  @override
  String get allReminders => 'All reminders';

  @override
  String nextNote(String when) {
    return 'Next: $when';
  }

  @override
  String get changeHour => 'Change the hour';

  @override
  String get turnOff => 'Turn this off';

  @override
  String get practiceIntro =>
      'What we remind you of, and when. Tap one to see what it means.';

  @override
  String get nothingOn => 'Nothing is on yet.';

  @override
  String get allRemindersWhy =>
      'Every switch, one by one. For when you know just what you want.';

  @override
  String get hourSheetWhy => 'Your five verses wait for you at this hour.';

  @override
  String get verseHour => 'Verse hour';

  @override
  String get weekdayLamp => 'A weekday lamp';

  @override
  String get savePractice => 'Save my practice';

  @override
  String itemAtTime(String label, String time) {
    return '$label, $time';
  }

  @override
  String ritualSemantic(String label, String meaning) {
    return '$label. $meaning';
  }

  @override
  String get traditionCaps => 'SMARTA AND VAISHNAVA';

  @override
  String get traditionExplTitle => 'Two ways to keep Ekadashi';

  @override
  String get traditionTithi =>
      'The moon has its own days. Each one is called a tithi. A tithi does not start at midnight. It can start at any hour.';

  @override
  String get traditionEkadashi =>
      'Ekadashi is the eleventh tithi. Dashami, the tenth, comes just before it.';

  @override
  String get traditionSmartaRule =>
      'Fast on the day Ekadashi is there when the sun rises.';

  @override
  String get traditionVaishnavaRule =>
      'Ekadashi must be clean from dawn, about an hour and a half before sunrise. If Dashami is still there at dawn, fast the next day.';

  @override
  String get traditionSame => 'Most months, both fall on the same day.';

  @override
  String get traditionUnsureLine =>
      'Not sure? Follow what your family does. You can change this later.';

  @override
  String get traditionRare =>
      'In a few months the moon moves fast and other rules decide. Our dates match Drik Panchang where we checked.';

  @override
  String get gotIt => 'Got it';

  @override
  String get timelineSemantic =>
      'Two sunrises. Dashami ends after dawn on day 1. The Smarta lamp stays on day 1. The Vaishnava lamp moves to day 2.';

  @override
  String get tlDashami => 'DASHAMI';

  @override
  String get tlEkadashi => 'EKADASHI';

  @override
  String get tlDvadashi => 'DVADASHI';

  @override
  String get tlDay1 => 'DAY 1';

  @override
  String get tlDay2 => 'DAY 2';

  @override
  String get tlDawn => 'DAWN';

  @override
  String get tlSmarta => 'SMARTA';

  @override
  String get tlVaishnava => 'VAISHNAVA';

  @override
  String clockRange(String same, String aBare, String aFull, String bFull) {
    String _temp0 = intl.Intl.selectLogic(same, {
      'yes': '$aBare-$bFull',
      'other': '$aFull-$bFull',
    });
    return '$_temp0';
  }

  @override
  String nameLead(String name) {
    return '$name.  ';
  }

  @override
  String get crisisTitle => 'You don’t have to carry this alone.';

  @override
  String get crisisBody =>
      'What you shared sounds very heavy. A trained person can help right now.';

  @override
  String get crisisCall => 'Call Tele-MANAS 14416';

  @override
  String get crisisDialFallback =>
      'Dial 14416 or 1-800-891-4416 from your phone.';

  @override
  String get crisisFree =>
      'Free, any time, in many languages. Also 1-800-891-4416.';

  @override
  String get crisisEmergency => 'Call 112 if you are in danger now';

  @override
  String get crisisEmergencyFallback => 'Dial 112 from your phone.';

  @override
  String get crisisMessage => 'Message someone I trust';

  @override
  String get crisisSmsBody => 'Can you call me? I’m having a hard time.';

  @override
  String crisisSmsFallback(String text) {
    return 'Send someone you trust: “$text”';
  }

  @override
  String get crisisBreathe => 'Stay here and breathe';

  @override
  String get crisisNothingKept =>
      'Nothing you wrote was kept. No points, no record.';

  @override
  String get breatheSemantic => 'Breathe in for 4 seconds, and out for 6.';

  @override
  String get breatheStill => 'In for 4. Out for 6.';

  @override
  String get breatheIn => 'Breathe in';

  @override
  String get breatheOut => 'Breathe out';

  @override
  String get authShortNumber => 'That number looks too short.';

  @override
  String get authShortCode => 'The code has six numbers.';

  @override
  String get authSignInFirst => 'Sign in first.';

  @override
  String get friendName => 'Friend';

  @override
  String get ekWrite => 'Write';

  @override
  String get ekSpeak => 'Speak';

  @override
  String get ekDoorPrivacy =>
      'Your words stay on this phone. Let them fade when you are done, or keep them.';

  @override
  String get ekDoorWaiting => 'Your last conversation is still here.';

  @override
  String get ekSend => 'Send';

  @override
  String get ekWriteHint => 'Write here';

  @override
  String get ekAnswerHint => 'Answer, or say more';

  @override
  String get ekYouSaid => 'You said';

  @override
  String get ekEkantSaid => 'Ekant';

  @override
  String get ekReflecting => 'Ekant is reflecting';

  @override
  String get ekCopy => 'Copy';

  @override
  String get ekCopied => 'Copied';

  @override
  String get ekStudy => 'Read this verse';

  @override
  String get ekFailedNote => 'The room went quiet. Please try again.';

  @override
  String get ekShareFooter => 'From Ekant, in DharmaScroll';

  @override
  String get ekOpen1 => 'Work has been weighing on me.';

  @override
  String get ekOpen2 => 'I cannot stop worrying.';

  @override
  String get ekOpen3 => 'I feel alone today.';

  @override
  String get ekOpen4 => 'I am angry and cannot let it go.';

  @override
  String get ekConnecting => 'Getting ready';

  @override
  String get ekIdle => 'Ready';

  @override
  String get ekListening => 'Listening';

  @override
  String get ekThinking => 'Thinking';

  @override
  String get ekSpeaking => 'Speaking';

  @override
  String get ekMuted => 'Muted';

  @override
  String get ekConnectFailed => 'Could not connect';

  @override
  String get ekMute => 'Mute';

  @override
  String get ekUnmute => 'Unmute';

  @override
  String get ekEnd => 'End';

  @override
  String get ekSwitchToChat => 'Switch to chat';

  @override
  String get ekHandsFree => 'Hands-free';

  @override
  String get ekPushToTalk => 'Push to talk';

  @override
  String get ekHoldToTalk => 'Hold to talk';

  @override
  String get ekRelease => 'Release when done';

  @override
  String get ekYou => 'You';

  @override
  String get ekCaptionsEmpty => 'Words appear here as you speak.';

  @override
  String get ekRetry => 'Try again';

  @override
  String get ekMicTitle => 'Use your microphone?';

  @override
  String get ekMicBody =>
      'To talk, the phone needs to hear you. Sound is only used while this room is open. The room shows your words as you speak.';

  @override
  String get ekMicAllow => 'Allow microphone';

  @override
  String get ekMicDenied =>
      'The microphone is off. You can allow it in the phone settings, or write instead.';

  @override
  String get ekPrompt => 'What is on your mind?';

  @override
  String get ekRest => 'Rest now';

  @override
  String get ekFade => 'Let it fade';

  @override
  String get ekKeep => 'Keep on this phone';

  @override
  String get ekReturn => 'Return';

  @override
  String get ekEnough => 'That is enough for this sitting.';

  @override
  String get ekKeepFailed => 'Could not keep it on this phone. Try again.';

  @override
  String get ekLeaveRoom => 'Leave the room';

  @override
  String get ekLeaveCaps => 'LEAVE';

  @override
  String get ekQuietRoom => 'A quiet room.';

  @override
  String get ekNoOne =>
      'No one is here. The app finds a verse of the Gita. Only the verse is the Gita’s word.';

  @override
  String get ekDanger =>
      'In danger? Call 112. Tele-MANAS 14416 is free, any time.';

  @override
  String ekKeptNotesBtn(int n) {
    return 'Kept notes ($n)';
  }

  @override
  String get ekVerseToCarry => 'A verse to carry';

  @override
  String get ekYourWords => 'Your words';

  @override
  String get ekRestNow => 'Rest now.';

  @override
  String get ekKeptOnly => 'Kept on this phone only. The verse stays.';

  @override
  String get ekGone => 'Your words have gone. The verse stays.';

  @override
  String ekVerseSemantic(
    String attribution,
    int chapter,
    int number,
    String meaning,
  ) {
    return '$attribution Gita chapter $chapter, verse $number. $meaning';
  }

  @override
  String ekVerseCardSemantic(
    int chapter,
    int number,
    String meaning,
    String study,
  ) {
    return 'Gita chapter $chapter, verse $number. $meaning. $study';
  }

  @override
  String ekGitaStudy(String id, String study) {
    return 'Gita $id. $study';
  }

  @override
  String ekGitaStudyCaps(String id, String study) {
    return 'GITA $id  ·  $study';
  }

  @override
  String get ekKeptNotes => 'Kept notes';

  @override
  String get ekKeptNotesWhy => 'On this phone only, encrypted.';

  @override
  String get ekDelete => 'Delete';

  @override
  String ekNoteHead(String date, String id) {
    return '$date  ·  GITA $id';
  }

  @override
  String get ekVoiceUnavailable => 'Voice is not available here. Typing works.';

  @override
  String get ekTalkOutLoud => 'Talk to Ekant out loud';

  @override
  String get ekWriteIntro =>
      'Write it as it comes. Hindi, English or Hinglish.';

  @override
  String get ekDictate => 'Dictate';

  @override
  String get exSimpleLabel => 'In simple words';

  @override
  String get exSimpleHead => 'What it means';

  @override
  String get exWordsLabel => 'Word by word';

  @override
  String get exWordsHead => 'One word at a time';

  @override
  String get exMomentLabel => 'The moment';

  @override
  String get exMomentHead => 'Kurukshetra, at dawn';

  @override
  String get exRelatedLabel => 'Related verses';

  @override
  String get exRelatedHead => 'On the same path';

  @override
  String get exMyDayLabel => 'For my day';

  @override
  String get exMyDayHead => 'One line from you';

  @override
  String get exDraftNote =>
      'Written for this app. Draft, pending scholar review.';

  @override
  String get exOfflineNote =>
      'Replies written with AI are coming. For now the verse answers from your phone.';

  @override
  String get exAskHint => 'What is on your mind today?';

  @override
  String get exAskLabel => 'Show me';

  @override
  String exBackTo(String id) {
    return 'Back to Gita $id';
  }

  @override
  String exVerseSemantic(String id, String sanskrit) {
    return 'Verse $id. $sanskrit';
  }

  @override
  String get exListen => 'Listen';

  @override
  String get exListenHint => 'Press and hold to listen';

  @override
  String get exWordsNote =>
      'Word meanings in English. Draft, pending scholar review.';

  @override
  String exSpeaksTo(String speaker, String listener) {
    return '$speaker speaks to $listener.';
  }

  @override
  String exChapterHead(int chapter, String yoga) {
    return 'ADHYAY $chapter · $yoga';
  }

  @override
  String exOpenGita(String id) {
    return 'Open Gita $id';
  }

  @override
  String get exOfflineCaps => 'OFFLINE · FROM YOUR PHONE';

  @override
  String get exBusy => 'Listening to the verse';

  @override
  String get exBySoftware => 'Written by software, from the verse.';

  @override
  String get exFromPhone => 'From your phone. Not a teacher or a counsellor.';

  @override
  String get exStoryOnly =>
      'This verse is part of the story, not advice for your day. This one may sit closer to you.';

  @override
  String exSaid(String speaker, String listener, String situations) {
    return '$speaker told $listener this for moments of $situations.';
  }

  @override
  String exListAnd(String rest, String last) {
    return '$rest and $last';
  }

  @override
  String exCarry(String said) {
    return '$said Carry one line of it with you today.';
  }

  @override
  String exMeets(String said, String tag) {
    return '$said It meets the $tag you wrote about. Read it once more, slowly.';
  }

  @override
  String exCloser(String said, String tag, String id) {
    return '$said For $tag, Gita $id may sit closer.';
  }

  @override
  String exHold(String said) {
    return '$said Hold your day up to it and see what stays.';
  }
}
