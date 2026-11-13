import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @whatIs.
  ///
  /// In en, this message translates to:
  /// **'What is {topic}?'**
  String whatIs(String topic);

  /// No description provided for @progressOf.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total}'**
  String progressOf(int n, int total);

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @moreLanguages.
  ///
  /// In en, this message translates to:
  /// **'More languages'**
  String get moreLanguages;

  /// No description provided for @languageSoonSemantic.
  ///
  /// In en, this message translates to:
  /// **'{name}, coming soon, not ready yet'**
  String languageSoonSemantic(String name);

  /// No description provided for @textSizeRow.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSizeRow;

  /// No description provided for @textSizeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'TEXT SIZE'**
  String get textSizeEyebrow;

  /// No description provided for @textSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'How big should\nthe words be?'**
  String get textSizeTitle;

  /// No description provided for @textSizeWhy.
  ///
  /// In en, this message translates to:
  /// **'Pick the size that is easy on your eyes. You can change it later.'**
  String get textSizeWhy;

  /// No description provided for @textSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get textSizeNormal;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @textSizeExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get textSizeExtraLarge;

  /// No description provided for @textSizeSample.
  ///
  /// In en, this message translates to:
  /// **'The lamp is lit. Five verses are waiting for you.'**
  String get textSizeSample;

  /// No description provided for @textSizeRowWhy.
  ///
  /// In en, this message translates to:
  /// **'Make the words bigger or smaller.'**
  String get textSizeRowWhy;

  /// No description provided for @welcomeLine1.
  ///
  /// In en, this message translates to:
  /// **'A conversation'**
  String get welcomeLine1;

  /// No description provided for @welcomeLine2.
  ///
  /// In en, this message translates to:
  /// **'on a battlefield.'**
  String get welcomeLine2;

  /// No description provided for @welcomeSub.
  ///
  /// In en, this message translates to:
  /// **'Five thousand years old.\nListen in.'**
  String get welcomeSub;

  /// No description provided for @welcomeButton.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get welcomeButton;

  /// No description provided for @eyebrowLight.
  ///
  /// In en, this message translates to:
  /// **'YOUR LIGHT'**
  String get eyebrowLight;

  /// No description provided for @eyebrowCity.
  ///
  /// In en, this message translates to:
  /// **'YOUR CITY'**
  String get eyebrowCity;

  /// No description provided for @eyebrowTradition.
  ///
  /// In en, this message translates to:
  /// **'YOUR TRADITION'**
  String get eyebrowTradition;

  /// No description provided for @eyebrowHour.
  ///
  /// In en, this message translates to:
  /// **'YOUR HOUR'**
  String get eyebrowHour;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is lighting\nthe lamp?'**
  String get signInTitle;

  /// No description provided for @cityTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you\nwatch the sun?'**
  String get cityTitle;

  /// No description provided for @traditionTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you\nkeep Ekadashi?'**
  String get traditionTitle;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'When does your\nday begin?'**
  String get reminderTitle;

  /// No description provided for @finishLabel.
  ///
  /// In en, this message translates to:
  /// **'Light the first lamp'**
  String get finishLabel;

  /// No description provided for @whySignIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in will keep your lamp and your verses if you change phones. For now, all of it stays on this phone.'**
  String get whySignIn;

  /// No description provided for @whyCity.
  ///
  /// In en, this message translates to:
  /// **'Your city tells us when the sun rises for you. Prayers follow the sun.'**
  String get whyCity;

  /// No description provided for @whyTradition.
  ///
  /// In en, this message translates to:
  /// **'Families keep the Ekadashi fast in two ways. Some months, the days differ.'**
  String get whyTradition;

  /// No description provided for @whyHour.
  ///
  /// In en, this message translates to:
  /// **'Five verses will wait for you at this hour. Every day, the same quiet time.'**
  String get whyHour;

  /// No description provided for @seeDifference.
  ///
  /// In en, this message translates to:
  /// **'See the difference'**
  String get seeDifference;

  /// No description provided for @topicSmartaVaishnava.
  ///
  /// In en, this message translates to:
  /// **'Smarta and Vaishnava'**
  String get topicSmartaVaishnava;

  /// No description provided for @traditionSmarta.
  ///
  /// In en, this message translates to:
  /// **'Smarta'**
  String get traditionSmarta;

  /// No description provided for @traditionVaishnava.
  ///
  /// In en, this message translates to:
  /// **'Vaishnava'**
  String get traditionVaishnava;

  /// No description provided for @traditionUnsure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get traditionUnsure;

  /// No description provided for @hintSmarta.
  ///
  /// In en, this message translates to:
  /// **'Fast on the day Ekadashi meets the sunrise.'**
  String get hintSmarta;

  /// No description provided for @hintVaishnava.
  ///
  /// In en, this message translates to:
  /// **'Wait for an Ekadashi that is clean from dawn.'**
  String get hintVaishnava;

  /// No description provided for @hintUnsure.
  ///
  /// In en, this message translates to:
  /// **'We show both days when they differ.'**
  String get hintUnsure;

  /// No description provided for @dragToChangeAm.
  ///
  /// In en, this message translates to:
  /// **'AM  ·  DRAG TO CHANGE'**
  String get dragToChangeAm;

  /// No description provided for @dragToChangePm.
  ///
  /// In en, this message translates to:
  /// **'PM  ·  DRAG TO CHANGE'**
  String get dragToChangePm;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTimeLabel;

  /// No description provided for @earlier15.
  ///
  /// In en, this message translates to:
  /// **'15 minutes earlier'**
  String get earlier15;

  /// No description provided for @later15.
  ///
  /// In en, this message translates to:
  /// **'15 minutes later'**
  String get later15;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search a city'**
  String get searchCity;

  /// No description provided for @signInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInGoogle;

  /// No description provided for @signInPhone.
  ///
  /// In en, this message translates to:
  /// **'Continue with phone'**
  String get signInPhone;

  /// No description provided for @signInGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get signInGuest;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send the code'**
  String get sendCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @codeNote.
  ///
  /// In en, this message translates to:
  /// **'We send a six-number code to this phone.'**
  String get codeNote;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String codeSentTo(String phone);

  /// No description provided for @otherWays.
  ///
  /// In en, this message translates to:
  /// **'Other ways to sign in'**
  String get otherWays;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change the number'**
  String get changeNumber;

  /// No description provided for @sixNumberCode.
  ///
  /// In en, this message translates to:
  /// **'Six-number code'**
  String get sixNumberCode;

  /// No description provided for @practiceEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR PRACTICE  ·  {n} OF {total}'**
  String practiceEyebrow(int n, int total);

  /// No description provided for @practiceQ1.
  ///
  /// In en, this message translates to:
  /// **'Do you keep\na fast?'**
  String get practiceQ1;

  /// No description provided for @practiceQ2.
  ///
  /// In en, this message translates to:
  /// **'Which day\nfeels like yours?'**
  String get practiceQ2;

  /// No description provided for @practiceQ3.
  ///
  /// In en, this message translates to:
  /// **'Do you light\na lamp at dusk?'**
  String get practiceQ3;

  /// No description provided for @practiceQ4.
  ///
  /// In en, this message translates to:
  /// **'A quiet minute\nat sunrise?'**
  String get practiceQ4;

  /// No description provided for @practiceQ5.
  ///
  /// In en, this message translates to:
  /// **'The full moon\nand big days?'**
  String get practiceQ5;

  /// No description provided for @practiceWhy1.
  ///
  /// In en, this message translates to:
  /// **'Ekadashi is the eleventh day of the moon. It comes twice a month. Many people fast on it.'**
  String get practiceWhy1;

  /// No description provided for @practiceWhy2.
  ///
  /// In en, this message translates to:
  /// **'Many homes keep one day of the week for one god. Pick one, or none.'**
  String get practiceWhy2;

  /// No description provided for @practiceWhy3.
  ///
  /// In en, this message translates to:
  /// **'Dusk is when day turns into night. A small lamp then is an old way to say thank you.'**
  String get practiceWhy3;

  /// No description provided for @practiceWhy4.
  ///
  /// In en, this message translates to:
  /// **'Sandhya means the meeting of night and day. One still minute as the sun comes up.'**
  String get practiceWhy4;

  /// No description provided for @practiceWhy5.
  ///
  /// In en, this message translates to:
  /// **'Purnima is the full moon. Amavasya is the night with no moon. Big days like Diwali fall on them.'**
  String get practiceWhy5;

  /// No description provided for @yesEkadashi.
  ///
  /// In en, this message translates to:
  /// **'Yes, on Ekadashi'**
  String get yesEkadashi;

  /// No description provided for @yesEvenings.
  ///
  /// In en, this message translates to:
  /// **'Yes, most evenings'**
  String get yesEvenings;

  /// No description provided for @yesPlease.
  ///
  /// In en, this message translates to:
  /// **'Yes, please'**
  String get yesPlease;

  /// No description provided for @yesTellMe.
  ///
  /// In en, this message translates to:
  /// **'Yes, tell me'**
  String get yesTellMe;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @noDay.
  ///
  /// In en, this message translates to:
  /// **'No day for now'**
  String get noDay;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @godShiva.
  ///
  /// In en, this message translates to:
  /// **'Shiva'**
  String get godShiva;

  /// No description provided for @godHanuman.
  ///
  /// In en, this message translates to:
  /// **'Hanuman'**
  String get godHanuman;

  /// No description provided for @godVishnu.
  ///
  /// In en, this message translates to:
  /// **'Vishnu, Guru'**
  String get godVishnu;

  /// No description provided for @godShani.
  ///
  /// In en, this message translates to:
  /// **'Shani'**
  String get godShani;

  /// No description provided for @firstNoteTag.
  ///
  /// In en, this message translates to:
  /// **'YOUR FIRST NOTE'**
  String get firstNoteTag;

  /// No description provided for @firstNoteSemantic.
  ///
  /// In en, this message translates to:
  /// **'Your first note. {when}. {body}'**
  String firstNoteSemantic(String when, String body);

  /// No description provided for @timedToSun.
  ///
  /// In en, this message translates to:
  /// **'Timed to your sun'**
  String get timedToSun;

  /// No description provided for @timeFromCity.
  ///
  /// In en, this message translates to:
  /// **'We work out the time from your city.'**
  String get timeFromCity;

  /// No description provided for @nothingSoon.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the next few weeks. We will tell you when it comes.'**
  String get nothingSoon;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabYatra.
  ///
  /// In en, this message translates to:
  /// **'Yatra'**
  String get tabYatra;

  /// No description provided for @tabYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get tabYou;

  /// No description provided for @todayBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin today\'s ritual'**
  String get todayBegin;

  /// No description provided for @todayContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue the ritual'**
  String get todayContinue;

  /// No description provided for @todayAgain.
  ///
  /// In en, this message translates to:
  /// **'Light it again'**
  String get todayAgain;

  /// No description provided for @todayHearAgain.
  ///
  /// In en, this message translates to:
  /// **'Hear them again'**
  String get todayHearAgain;

  /// No description provided for @todayDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Today is lit.'**
  String get todayDoneTitle;

  /// No description provided for @todayCameBack.
  ///
  /// In en, this message translates to:
  /// **'You came back.'**
  String get todayCameBack;

  /// No description provided for @todayWalkedTitle.
  ///
  /// In en, this message translates to:
  /// **'The lamp is lit.\nNow, speak your mind.'**
  String get todayWalkedTitle;

  /// No description provided for @todayHeardTitle.
  ///
  /// In en, this message translates to:
  /// **'Five heard.\nNow take one step\non the path.'**
  String get todayHeardTitle;

  /// No description provided for @greetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning.'**
  String get greetMorning;

  /// No description provided for @greetMorningName.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}.'**
  String greetMorningName(String name);

  /// No description provided for @greetNamaste.
  ///
  /// In en, this message translates to:
  /// **'Namaste.'**
  String get greetNamaste;

  /// No description provided for @greetNamasteName.
  ///
  /// In en, this message translates to:
  /// **'Namaste, {name}.'**
  String greetNamasteName(String name);

  /// No description provided for @todaySubBack.
  ///
  /// In en, this message translates to:
  /// **'The lamp was still warm.'**
  String get todaySubBack;

  /// No description provided for @todaySubDone.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow.\nThe verses will wait.'**
  String get todaySubDone;

  /// No description provided for @todaySubWalked.
  ///
  /// In en, this message translates to:
  /// **'A verse will answer.'**
  String get todaySubWalked;

  /// No description provided for @todaySubStart.
  ///
  /// In en, this message translates to:
  /// **'Five verses are waiting.\nThen you may rest.'**
  String get todaySubStart;

  /// No description provided for @topDay.
  ///
  /// In en, this message translates to:
  /// **'Day {n}'**
  String topDay(int n);

  /// No description provided for @topAdhyaya.
  ///
  /// In en, this message translates to:
  /// **'Adhyaya {n}'**
  String topAdhyaya(int n);

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today in your calendar: {items}'**
  String calendarToday(String items);

  /// No description provided for @pointsAction.
  ///
  /// In en, this message translates to:
  /// **'{n} Moksh Points'**
  String pointsAction(int n);

  /// No description provided for @ekantAction.
  ///
  /// In en, this message translates to:
  /// **'Ekant, a quiet room'**
  String get ekantAction;

  /// No description provided for @daysKept.
  ///
  /// In en, this message translates to:
  /// **'Your {n} days are kept.'**
  String daysKept(int n);

  /// No description provided for @earlierDaysKept.
  ///
  /// In en, this message translates to:
  /// **'Your earlier days are kept.'**
  String get earlierDaysKept;

  /// No description provided for @railHear.
  ///
  /// In en, this message translates to:
  /// **'Hear'**
  String get railHear;

  /// No description provided for @railWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get railWalk;

  /// No description provided for @railSpeak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get railSpeak;

  /// No description provided for @railDone.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get railDone;

  /// No description provided for @railNext.
  ///
  /// In en, this message translates to:
  /// **'next'**
  String get railNext;

  /// No description provided for @railLater.
  ///
  /// In en, this message translates to:
  /// **'later'**
  String get railLater;

  /// No description provided for @railSemantic.
  ///
  /// In en, this message translates to:
  /// **'{label}, {state}'**
  String railSemantic(String label, String state);

  /// No description provided for @youTitle.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youTitle;

  /// No description provided for @yourLight.
  ///
  /// In en, this message translates to:
  /// **'Your light'**
  String get yourLight;

  /// No description provided for @daysOfLightOne.
  ///
  /// In en, this message translates to:
  /// **'1 day of light'**
  String get daysOfLightOne;

  /// No description provided for @daysOfLight.
  ///
  /// In en, this message translates to:
  /// **'{n} days of light'**
  String daysOfLight(int n);

  /// No description provided for @keptVerses.
  ///
  /// In en, this message translates to:
  /// **'Kept verses'**
  String get keptVerses;

  /// No description provided for @mokshPoints.
  ///
  /// In en, this message translates to:
  /// **'Moksh Points'**
  String get mokshPoints;

  /// No description provided for @ekantRow.
  ///
  /// In en, this message translates to:
  /// **'Ekant'**
  String get ekantRow;

  /// No description provided for @ekantWhy.
  ///
  /// In en, this message translates to:
  /// **'A quiet room to sit with what you feel.'**
  String get ekantWhy;

  /// No description provided for @settingsHead.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsHead;

  /// No description provided for @practiceRow.
  ///
  /// In en, this message translates to:
  /// **'My practice'**
  String get practiceRow;

  /// No description provided for @practiceRowWhy.
  ///
  /// In en, this message translates to:
  /// **'What we remind you of, and when.'**
  String get practiceRowWhy;

  /// No description provided for @practiceRowValue.
  ///
  /// In en, this message translates to:
  /// **'{n} on'**
  String practiceRowValue(int n);

  /// No description provided for @placeRow.
  ///
  /// In en, this message translates to:
  /// **'City and tradition'**
  String get placeRow;

  /// No description provided for @placeRowWhy.
  ///
  /// In en, this message translates to:
  /// **'Your sunrise, and your Ekadashi day.'**
  String get placeRowWhy;

  /// No description provided for @soundRow.
  ///
  /// In en, this message translates to:
  /// **'Sound and touch'**
  String get soundRow;

  /// No description provided for @soundRowWhy.
  ///
  /// In en, this message translates to:
  /// **'Soft sounds and small taps you can feel.'**
  String get soundRowWhy;

  /// No description provided for @languageRowWhy.
  ///
  /// In en, this message translates to:
  /// **'The words in the app, and the meaning of each verse.'**
  String get languageRowWhy;

  /// No description provided for @lookRow.
  ///
  /// In en, this message translates to:
  /// **'Look'**
  String get lookRow;

  /// No description provided for @lookRowWhy.
  ///
  /// In en, this message translates to:
  /// **'Night or morning light.'**
  String get lookRowWhy;

  /// No description provided for @accountRow.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountRow;

  /// No description provided for @accountRowWhy.
  ///
  /// In en, this message translates to:
  /// **'Who you are. It stays on this phone.'**
  String get accountRowWhy;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @methodNone.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get methodNone;

  /// No description provided for @methodGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest on this phone'**
  String get methodGuest;

  /// No description provided for @methodGoogle.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Google'**
  String get methodGoogle;

  /// No description provided for @methodPhone.
  ///
  /// In en, this message translates to:
  /// **'Signed in with {phone}'**
  String methodPhone(String phone);

  /// No description provided for @phoneWord.
  ///
  /// In en, this message translates to:
  /// **'phone'**
  String get phoneWord;

  /// No description provided for @placeSheetWhy.
  ///
  /// In en, this message translates to:
  /// **'Your city tells us when the sun rises for you. Prayers follow the sun.'**
  String get placeSheetWhy;

  /// No description provided for @yourCity.
  ///
  /// In en, this message translates to:
  /// **'Your city'**
  String get yourCity;

  /// No description provided for @whyYourCity.
  ///
  /// In en, this message translates to:
  /// **'Why your city?'**
  String get whyYourCity;

  /// No description provided for @cityInfo1.
  ///
  /// In en, this message translates to:
  /// **'The sun rises at a different time in every city.'**
  String get cityInfo1;

  /// No description provided for @cityInfo2.
  ///
  /// In en, this message translates to:
  /// **'Sunrise starts each day of the moon. So your city sets the right day and hour for every fast and lamp.'**
  String get cityInfo2;

  /// No description provided for @howYouKeepEkadashi.
  ///
  /// In en, this message translates to:
  /// **'How you keep Ekadashi'**
  String get howYouKeepEkadashi;

  /// No description provided for @soundSheetWhy.
  ///
  /// In en, this message translates to:
  /// **'Small signs that the app heard you.'**
  String get soundSheetWhy;

  /// No description provided for @soundLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundLabel;

  /// No description provided for @soundWhy.
  ///
  /// In en, this message translates to:
  /// **'Soft bells and wood taps.'**
  String get soundWhy;

  /// No description provided for @soundInfo1.
  ///
  /// In en, this message translates to:
  /// **'When you press a button, you hear a soft tap.'**
  String get soundInfo1;

  /// No description provided for @soundInfo2.
  ///
  /// In en, this message translates to:
  /// **'When you finish a step, a small bell rings.'**
  String get soundInfo2;

  /// No description provided for @soundInfo3.
  ///
  /// In en, this message translates to:
  /// **'It is always quiet and short. Your phone volume still decides.'**
  String get soundInfo3;

  /// No description provided for @hapticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Touch'**
  String get hapticsLabel;

  /// No description provided for @hapticsWhy.
  ///
  /// In en, this message translates to:
  /// **'A tiny tap you feel in your hand.'**
  String get hapticsWhy;

  /// No description provided for @hapticsInfo1.
  ///
  /// In en, this message translates to:
  /// **'Touch means the phone moves a tiny bit, like a soft knock.'**
  String get hapticsInfo1;

  /// No description provided for @hapticsInfo2.
  ///
  /// In en, this message translates to:
  /// **'You feel it when you pick something or finish a step.'**
  String get hapticsInfo2;

  /// No description provided for @lookSheetWhy.
  ///
  /// In en, this message translates to:
  /// **'How the app looks.'**
  String get lookSheetWhy;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get appearanceAuto;

  /// No description provided for @appearanceAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Today turns bright like morning, from 5 to 10.'**
  String get appearanceAutoHint;

  /// No description provided for @appearanceNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get appearanceNight;

  /// No description provided for @appearanceNightHint.
  ///
  /// In en, this message translates to:
  /// **'Always the warm dark, all day.'**
  String get appearanceNightHint;

  /// No description provided for @languageSheetWhy.
  ///
  /// In en, this message translates to:
  /// **'The words in the app, and the meaning shown under each verse.'**
  String get languageSheetWhy;

  /// No description provided for @languageEnglishHint.
  ///
  /// In en, this message translates to:
  /// **'The app and the meanings in English.'**
  String get languageEnglishHint;

  /// No description provided for @languageHindiHint.
  ///
  /// In en, this message translates to:
  /// **'The app and the meanings in Hindi.'**
  String get languageHindiHint;

  /// No description provided for @textSizeSheetWhy.
  ///
  /// In en, this message translates to:
  /// **'Pick the size that is easy on your eyes.'**
  String get textSizeSheetWhy;

  /// No description provided for @accountSheetWhy.
  ///
  /// In en, this message translates to:
  /// **'Who you are here. Your data stays on this phone.'**
  String get accountSheetWhy;

  /// No description provided for @whatToCall.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get whatToCall;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @signInToKeep.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep your lamp if you change phones.'**
  String get signInToKeep;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get yourData;

  /// No description provided for @whatStaysTitle.
  ///
  /// In en, this message translates to:
  /// **'What stays with you'**
  String get whatStaysTitle;

  /// No description provided for @dataInfo1.
  ///
  /// In en, this message translates to:
  /// **'Your lamp, your points and your kept verses live on this phone.'**
  String get dataInfo1;

  /// No description provided for @dataInfo2.
  ///
  /// In en, this message translates to:
  /// **'Nothing you speak is stored. It is heard, then let go.'**
  String get dataInfo2;

  /// No description provided for @dataInfo3.
  ///
  /// In en, this message translates to:
  /// **'Signing in is only pretend for now. Nothing leaves this phone.'**
  String get dataInfo3;

  /// No description provided for @dataLine.
  ///
  /// In en, this message translates to:
  /// **'Your progress lives on this phone. Nothing you speak is stored.'**
  String get dataLine;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @personKrishna.
  ///
  /// In en, this message translates to:
  /// **'Krishna'**
  String get personKrishna;

  /// No description provided for @personArjuna.
  ///
  /// In en, this message translates to:
  /// **'Arjuna'**
  String get personArjuna;

  /// No description provided for @personSanjaya.
  ///
  /// In en, this message translates to:
  /// **'Sanjaya'**
  String get personSanjaya;

  /// No description provided for @personDhritarashtra.
  ///
  /// In en, this message translates to:
  /// **'Dhritarashtra'**
  String get personDhritarashtra;

  /// No description provided for @yoga1.
  ///
  /// In en, this message translates to:
  /// **'Arjuna Vishada Yoga'**
  String get yoga1;

  /// No description provided for @yoga2.
  ///
  /// In en, this message translates to:
  /// **'Sankhya Yoga'**
  String get yoga2;

  /// No description provided for @yoga3.
  ///
  /// In en, this message translates to:
  /// **'Karma Yoga'**
  String get yoga3;

  /// No description provided for @yoga4.
  ///
  /// In en, this message translates to:
  /// **'Jnana Karma Sannyasa Yoga'**
  String get yoga4;

  /// No description provided for @yoga5.
  ///
  /// In en, this message translates to:
  /// **'Karma Sannyasa Yoga'**
  String get yoga5;

  /// No description provided for @yoga6.
  ///
  /// In en, this message translates to:
  /// **'Dhyana Yoga'**
  String get yoga6;

  /// No description provided for @yoga7.
  ///
  /// In en, this message translates to:
  /// **'Jnana Vijnana Yoga'**
  String get yoga7;

  /// No description provided for @yoga8.
  ///
  /// In en, this message translates to:
  /// **'Akshara Brahma Yoga'**
  String get yoga8;

  /// No description provided for @yoga9.
  ///
  /// In en, this message translates to:
  /// **'Raja Vidya Raja Guhya Yoga'**
  String get yoga9;

  /// No description provided for @yoga10.
  ///
  /// In en, this message translates to:
  /// **'Vibhuti Yoga'**
  String get yoga10;

  /// No description provided for @yoga11.
  ///
  /// In en, this message translates to:
  /// **'Vishvarupa Darshana Yoga'**
  String get yoga11;

  /// No description provided for @yoga12.
  ///
  /// In en, this message translates to:
  /// **'Bhakti Yoga'**
  String get yoga12;

  /// No description provided for @yoga13.
  ///
  /// In en, this message translates to:
  /// **'Kshetra Kshetrajna Vibhaga Yoga'**
  String get yoga13;

  /// No description provided for @yoga14.
  ///
  /// In en, this message translates to:
  /// **'Gunatraya Vibhaga Yoga'**
  String get yoga14;

  /// No description provided for @yoga15.
  ///
  /// In en, this message translates to:
  /// **'Purushottama Yoga'**
  String get yoga15;

  /// No description provided for @yoga16.
  ///
  /// In en, this message translates to:
  /// **'Daivasura Sampad Vibhaga Yoga'**
  String get yoga16;

  /// No description provided for @yoga17.
  ///
  /// In en, this message translates to:
  /// **'Shraddhatraya Vibhaga Yoga'**
  String get yoga17;

  /// No description provided for @yoga18.
  ///
  /// In en, this message translates to:
  /// **'Moksha Sannyasa Yoga'**
  String get yoga18;

  /// No description provided for @tagGrief.
  ///
  /// In en, this message translates to:
  /// **'grief'**
  String get tagGrief;

  /// No description provided for @tagLoss.
  ///
  /// In en, this message translates to:
  /// **'loss'**
  String get tagLoss;

  /// No description provided for @tagFear.
  ///
  /// In en, this message translates to:
  /// **'fear'**
  String get tagFear;

  /// No description provided for @tagAnxiety.
  ///
  /// In en, this message translates to:
  /// **'anxiety'**
  String get tagAnxiety;

  /// No description provided for @tagAnger.
  ///
  /// In en, this message translates to:
  /// **'anger'**
  String get tagAnger;

  /// No description provided for @tagEnvy.
  ///
  /// In en, this message translates to:
  /// **'envy'**
  String get tagEnvy;

  /// No description provided for @tagComparison.
  ///
  /// In en, this message translates to:
  /// **'comparison'**
  String get tagComparison;

  /// No description provided for @tagPride.
  ///
  /// In en, this message translates to:
  /// **'pride'**
  String get tagPride;

  /// No description provided for @tagDesire.
  ///
  /// In en, this message translates to:
  /// **'desire'**
  String get tagDesire;

  /// No description provided for @tagGreed.
  ///
  /// In en, this message translates to:
  /// **'greed'**
  String get tagGreed;

  /// No description provided for @tagRestlessness.
  ///
  /// In en, this message translates to:
  /// **'restlessness'**
  String get tagRestlessness;

  /// No description provided for @tagDoubt.
  ///
  /// In en, this message translates to:
  /// **'doubt'**
  String get tagDoubt;

  /// No description provided for @tagSelfDoubt.
  ///
  /// In en, this message translates to:
  /// **'self doubt'**
  String get tagSelfDoubt;

  /// No description provided for @tagConfusion.
  ///
  /// In en, this message translates to:
  /// **'confusion'**
  String get tagConfusion;

  /// No description provided for @tagLoneliness.
  ///
  /// In en, this message translates to:
  /// **'loneliness'**
  String get tagLoneliness;

  /// No description provided for @tagBurnout.
  ///
  /// In en, this message translates to:
  /// **'burnout'**
  String get tagBurnout;

  /// No description provided for @tagFailure.
  ///
  /// In en, this message translates to:
  /// **'failure'**
  String get tagFailure;

  /// No description provided for @tagSuccess.
  ///
  /// In en, this message translates to:
  /// **'success'**
  String get tagSuccess;

  /// No description provided for @tagExamStress.
  ///
  /// In en, this message translates to:
  /// **'exam stress'**
  String get tagExamStress;

  /// No description provided for @tagWorkPressure.
  ///
  /// In en, this message translates to:
  /// **'work pressure'**
  String get tagWorkPressure;

  /// No description provided for @tagDutyConflict.
  ///
  /// In en, this message translates to:
  /// **'duty conflict'**
  String get tagDutyConflict;

  /// No description provided for @tagProcrastination.
  ///
  /// In en, this message translates to:
  /// **'procrastination'**
  String get tagProcrastination;

  /// No description provided for @tagPerfectionism.
  ///
  /// In en, this message translates to:
  /// **'perfectionism'**
  String get tagPerfectionism;

  /// No description provided for @tagFocus.
  ///
  /// In en, this message translates to:
  /// **'focus'**
  String get tagFocus;

  /// No description provided for @tagDiscipline.
  ///
  /// In en, this message translates to:
  /// **'discipline'**
  String get tagDiscipline;

  /// No description provided for @tagHabits.
  ///
  /// In en, this message translates to:
  /// **'habits'**
  String get tagHabits;

  /// No description provided for @tagPatience.
  ///
  /// In en, this message translates to:
  /// **'patience'**
  String get tagPatience;

  /// No description provided for @tagEquanimity.
  ///
  /// In en, this message translates to:
  /// **'equanimity'**
  String get tagEquanimity;

  /// No description provided for @tagDetachment.
  ///
  /// In en, this message translates to:
  /// **'detachment'**
  String get tagDetachment;

  /// No description provided for @tagForgiveness.
  ///
  /// In en, this message translates to:
  /// **'forgiveness'**
  String get tagForgiveness;

  /// No description provided for @tagCompassion.
  ///
  /// In en, this message translates to:
  /// **'compassion'**
  String get tagCompassion;

  /// No description provided for @tagKindness.
  ///
  /// In en, this message translates to:
  /// **'kindness'**
  String get tagKindness;

  /// No description provided for @tagGratitude.
  ///
  /// In en, this message translates to:
  /// **'gratitude'**
  String get tagGratitude;

  /// No description provided for @tagHumility.
  ///
  /// In en, this message translates to:
  /// **'humility'**
  String get tagHumility;

  /// No description provided for @tagFaith.
  ///
  /// In en, this message translates to:
  /// **'faith'**
  String get tagFaith;

  /// No description provided for @tagSurrender.
  ///
  /// In en, this message translates to:
  /// **'surrender'**
  String get tagSurrender;

  /// No description provided for @tagPurpose.
  ///
  /// In en, this message translates to:
  /// **'purpose'**
  String get tagPurpose;

  /// No description provided for @tagMortality.
  ///
  /// In en, this message translates to:
  /// **'mortality'**
  String get tagMortality;

  /// No description provided for @tagChange.
  ///
  /// In en, this message translates to:
  /// **'change'**
  String get tagChange;

  /// No description provided for @tagSelfWorth.
  ///
  /// In en, this message translates to:
  /// **'self worth'**
  String get tagSelfWorth;

  /// No description provided for @tagSpeech.
  ///
  /// In en, this message translates to:
  /// **'speech'**
  String get tagSpeech;

  /// No description provided for @tagContentment.
  ///
  /// In en, this message translates to:
  /// **'contentment'**
  String get tagContentment;

  /// No description provided for @tagPeace.
  ///
  /// In en, this message translates to:
  /// **'peace'**
  String get tagPeace;

  /// No description provided for @tagHope.
  ///
  /// In en, this message translates to:
  /// **'hope'**
  String get tagHope;

  /// No description provided for @tagLearning.
  ///
  /// In en, this message translates to:
  /// **'learning'**
  String get tagLearning;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @shareLabel.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareLabel;

  /// No description provided for @shareVerse.
  ///
  /// In en, this message translates to:
  /// **'Share this verse'**
  String get shareVerse;

  /// No description provided for @gitaRef.
  ///
  /// In en, this message translates to:
  /// **'Gita {id}'**
  String gitaRef(String id);

  /// No description provided for @gitaRefCaps.
  ///
  /// In en, this message translates to:
  /// **'GITA {id}'**
  String gitaRefCaps(String id);

  /// No description provided for @listeningCaps.
  ///
  /// In en, this message translates to:
  /// **'LISTENING'**
  String get listeningCaps;

  /// No description provided for @hearEndTitle.
  ///
  /// In en, this message translates to:
  /// **'That is enough\nfor today.'**
  String get hearEndTitle;

  /// No description provided for @hearEndSub.
  ///
  /// In en, this message translates to:
  /// **'The verse will wait.'**
  String get hearEndSub;

  /// No description provided for @hearNext.
  ///
  /// In en, this message translates to:
  /// **'Walk the next step'**
  String get hearNext;

  /// No description provided for @hearRest.
  ///
  /// In en, this message translates to:
  /// **'Rest for now'**
  String get hearRest;

  /// No description provided for @explainVerse.
  ///
  /// In en, this message translates to:
  /// **'Explain this verse'**
  String get explainVerse;

  /// No description provided for @verseOfTotalCaps.
  ///
  /// In en, this message translates to:
  /// **'{n} OF {total}'**
  String verseOfTotalCaps(int n, int total);

  /// No description provided for @keptCaps.
  ///
  /// In en, this message translates to:
  /// **'KEPT'**
  String get keptCaps;

  /// No description provided for @holdToListen.
  ///
  /// In en, this message translates to:
  /// **'Hold to listen'**
  String get holdToListen;

  /// No description provided for @verseSemantic.
  ///
  /// In en, this message translates to:
  /// **'Verse {id}. {sanskrit}. {meaning}'**
  String verseSemantic(String id, String sanskrit, String meaning);

  /// No description provided for @verseHint.
  ///
  /// In en, this message translates to:
  /// **'Double tap to keep. Press and hold to listen.'**
  String get verseHint;

  /// No description provided for @walkEyebrow.
  ///
  /// In en, this message translates to:
  /// **'WALK  ·  STEP {n} OF 2'**
  String walkEyebrow(int n);

  /// No description provided for @speakerSaysTo.
  ///
  /// In en, this message translates to:
  /// **'{speaker} says to {listener}:'**
  String speakerSaysTo(String speaker, String listener);

  /// No description provided for @speakerSays.
  ///
  /// In en, this message translates to:
  /// **'{speaker} says:'**
  String speakerSays(String speaker);

  /// No description provided for @chantSemantic.
  ///
  /// In en, this message translates to:
  /// **'Chant along. Press and hold the ring. Activate to chant it all.'**
  String get chantSemantic;

  /// No description provided for @releaseToPause.
  ///
  /// In en, this message translates to:
  /// **'RELEASE TO PAUSE'**
  String get releaseToPause;

  /// No description provided for @holdToChant.
  ///
  /// In en, this message translates to:
  /// **'HOLD AND CHANT WITH THE VERSE'**
  String get holdToChant;

  /// No description provided for @meetsHead.
  ///
  /// In en, this message translates to:
  /// **'WHERE DOES THIS MEET YOU TODAY?'**
  String get meetsHead;

  /// No description provided for @meetsLine1.
  ///
  /// In en, this message translates to:
  /// **'A task I am afraid to begin'**
  String get meetsLine1;

  /// No description provided for @meetsLine2.
  ///
  /// In en, this message translates to:
  /// **'A result I cannot control'**
  String get meetsLine2;

  /// No description provided for @meetsLine3.
  ///
  /// In en, this message translates to:
  /// **'What others will think'**
  String get meetsLine3;

  /// No description provided for @thisOne.
  ///
  /// In en, this message translates to:
  /// **'This one'**
  String get thisOne;

  /// No description provided for @stepWalkedCaps.
  ///
  /// In en, this message translates to:
  /// **'STEP WALKED'**
  String get stepWalkedCaps;

  /// No description provided for @lampIsLit.
  ///
  /// In en, this message translates to:
  /// **'The lamp is lit.'**
  String get lampIsLit;

  /// No description provided for @mokshPointsCaps.
  ///
  /// In en, this message translates to:
  /// **'MOKSH POINTS'**
  String get mokshPointsCaps;

  /// No description provided for @dayAndLamps.
  ///
  /// In en, this message translates to:
  /// **'Day {day}  ·  {lit, plural, =1{one lamp} other{{lit} lamps}} this week'**
  String dayAndLamps(int day, int lit);

  /// No description provided for @shareStreak.
  ///
  /// In en, this message translates to:
  /// **'Share your streak'**
  String get shareStreak;

  /// No description provided for @checkpointCaps.
  ///
  /// In en, this message translates to:
  /// **'CHECKPOINT'**
  String get checkpointCaps;

  /// No description provided for @finishVerseTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish the verse'**
  String get finishVerseTitle;

  /// No description provided for @skipForToday.
  ///
  /// In en, this message translates to:
  /// **'Skip for today'**
  String get skipForToday;

  /// No description provided for @finishedVerse.
  ///
  /// In en, this message translates to:
  /// **'You finished the verse.'**
  String get finishedVerse;

  /// No description provided for @sayTheLine.
  ///
  /// In en, this message translates to:
  /// **'Say the second line, or tap it.'**
  String get sayTheLine;

  /// No description provided for @hiddenLineSemantic.
  ///
  /// In en, this message translates to:
  /// **'Hidden line, {n} of {total} words shown. Activate to reveal the next word.'**
  String hiddenLineSemantic(int n, int total);

  /// No description provided for @stopListening.
  ///
  /// In en, this message translates to:
  /// **'Stop listening'**
  String get stopListening;

  /// No description provided for @speakSecondLine.
  ///
  /// In en, this message translates to:
  /// **'Speak the second line'**
  String get speakSecondLine;

  /// No description provided for @tapToSpeakCaps.
  ///
  /// In en, this message translates to:
  /// **'TAP TO SPEAK'**
  String get tapToSpeakCaps;

  /// No description provided for @shareThisLight.
  ///
  /// In en, this message translates to:
  /// **'Share this light'**
  String get shareThisLight;

  /// No description provided for @daysUnbroken.
  ///
  /// In en, this message translates to:
  /// **'days, unbroken.'**
  String get daysUnbroken;

  /// No description provided for @msWeek.
  ///
  /// In en, this message translates to:
  /// **'A week of light'**
  String get msWeek;

  /// No description provided for @msMonth.
  ///
  /// In en, this message translates to:
  /// **'A month of light'**
  String get msMonth;

  /// No description provided for @msHundred.
  ///
  /// In en, this message translates to:
  /// **'A hundred lamps'**
  String get msHundred;

  /// No description provided for @msYear.
  ///
  /// In en, this message translates to:
  /// **'A year of light'**
  String get msYear;

  /// No description provided for @msDays.
  ///
  /// In en, this message translates to:
  /// **'Days of light'**
  String get msDays;

  /// No description provided for @msLine7.
  ///
  /// In en, this message translates to:
  /// **'Practise, and the mind\ngrows steady.'**
  String get msLine7;

  /// No description provided for @msLine30.
  ///
  /// In en, this message translates to:
  /// **'Each time the mind wanders,\nbring it gently back.'**
  String get msLine30;

  /// No description provided for @msLine100.
  ///
  /// In en, this message translates to:
  /// **'Steady in success and failure.\nThat evenness is yoga.'**
  String get msLine100;

  /// No description provided for @msLine365.
  ///
  /// In en, this message translates to:
  /// **'Whatever you do,\ndo it as an offering.'**
  String get msLine365;

  /// No description provided for @keptCount.
  ///
  /// In en, this message translates to:
  /// **'{n} kept'**
  String keptCount(int n);

  /// No description provided for @nothingKept.
  ///
  /// In en, this message translates to:
  /// **'Nothing kept yet.'**
  String get nothingKept;

  /// No description provided for @keptEmptyLine.
  ///
  /// In en, this message translates to:
  /// **'Double-tap a verse to keep it here.'**
  String get keptEmptyLine;

  /// No description provided for @goDeeperCaps.
  ///
  /// In en, this message translates to:
  /// **'GO DEEPER'**
  String get goDeeperCaps;

  /// No description provided for @inEnglish.
  ///
  /// In en, this message translates to:
  /// **'In English'**
  String get inEnglish;

  /// No description provided for @inHindi.
  ///
  /// In en, this message translates to:
  /// **'In Hindi'**
  String get inHindi;

  /// No description provided for @whoSpeaks.
  ///
  /// In en, this message translates to:
  /// **'Who speaks'**
  String get whoSpeaks;

  /// No description provided for @whoSpeaksText.
  ///
  /// In en, this message translates to:
  /// **'{speaker}, to {listener}.'**
  String whoSpeaksText(String speaker, String listener);

  /// No description provided for @whereSits.
  ///
  /// In en, this message translates to:
  /// **'Where it sits'**
  String get whereSits;

  /// No description provided for @whereSitsText.
  ///
  /// In en, this message translates to:
  /// **'{ref}, {yoga}.'**
  String whereSitsText(String ref, String yoga);

  /// No description provided for @verseRef.
  ///
  /// In en, this message translates to:
  /// **'Adhyay {chapter} · Shloka {number}'**
  String verseRef(int chapter, int number);

  /// No description provided for @whereMeetsLife.
  ///
  /// In en, this message translates to:
  /// **'Where it meets life'**
  String get whereMeetsLife;

  /// No description provided for @shareThisLightCaps.
  ///
  /// In en, this message translates to:
  /// **'SHARE THIS LIGHT'**
  String get shareThisLightCaps;

  /// No description provided for @layoutNight.
  ///
  /// In en, this message translates to:
  /// **'Temple night'**
  String get layoutNight;

  /// No description provided for @layoutIvory.
  ///
  /// In en, this message translates to:
  /// **'Morning ivory'**
  String get layoutIvory;

  /// No description provided for @layoutArch.
  ///
  /// In en, this message translates to:
  /// **'Temple arch'**
  String get layoutArch;

  /// No description provided for @layoutLampNight.
  ///
  /// In en, this message translates to:
  /// **'Lamp, night'**
  String get layoutLampNight;

  /// No description provided for @layoutLampMorning.
  ///
  /// In en, this message translates to:
  /// **'Lamp, morning'**
  String get layoutLampMorning;

  /// No description provided for @cardSemantic.
  ///
  /// In en, this message translates to:
  /// **'{label} card'**
  String cardSemantic(String label);

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// No description provided for @shareCardSemantic.
  ///
  /// In en, this message translates to:
  /// **'Share the {label} card as an image'**
  String shareCardSemantic(String label);

  /// No description provided for @shareTextStreak.
  ///
  /// In en, this message translates to:
  /// **'{n} days of light with the Bhagavad Gita. {app}'**
  String shareTextStreak(int n, String app);

  /// No description provided for @shareTextVerse.
  ///
  /// In en, this message translates to:
  /// **'Bhagavad Gita {id}: {meaning} {app}'**
  String shareTextVerse(String id, String meaning, String app);

  /// No description provided for @cardSpeaker.
  ///
  /// In en, this message translates to:
  /// **'{speaker} to {listener}  ·  {yoga}'**
  String cardSpeaker(String speaker, String listener, String yoga);

  /// No description provided for @dayOfLight.
  ///
  /// In en, this message translates to:
  /// **'day of light.'**
  String get dayOfLight;

  /// No description provided for @daysOfLightDot.
  ///
  /// In en, this message translates to:
  /// **'days of light.'**
  String get daysOfLightDot;

  /// No description provided for @fiveAdayThenRest.
  ///
  /// In en, this message translates to:
  /// **'Five verses a day, then rest.'**
  String get fiveAdayThenRest;

  /// No description provided for @month1.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get month1;

  /// No description provided for @month2.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get month2;

  /// No description provided for @month3.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get month3;

  /// No description provided for @month4.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get month4;

  /// No description provided for @month5.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get month5;

  /// No description provided for @month6.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get month6;

  /// No description provided for @month7.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get month7;

  /// No description provided for @month8.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get month8;

  /// No description provided for @month9.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get month9;

  /// No description provided for @month10.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get month10;

  /// No description provided for @month11.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get month11;

  /// No description provided for @month12.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get month12;

  /// No description provided for @dayMonth.
  ///
  /// In en, this message translates to:
  /// **'{day} {month}'**
  String dayMonth(int day, String month);

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @dayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dayYesterday;

  /// No description provided for @walletPromise.
  ///
  /// In en, this message translates to:
  /// **'They only go up.\nNothing here is for sale.'**
  String get walletPromise;

  /// No description provided for @howTheyCameCaps.
  ///
  /// In en, this message translates to:
  /// **'HOW THEY CAME'**
  String get howTheyCameCaps;

  /// No description provided for @firstPoints.
  ///
  /// In en, this message translates to:
  /// **'Your first points come with today\'s five verses.'**
  String get firstPoints;

  /// No description provided for @reasonHear.
  ///
  /// In en, this message translates to:
  /// **'Five verses heard'**
  String get reasonHear;

  /// No description provided for @reasonWalk.
  ///
  /// In en, this message translates to:
  /// **'One step walked'**
  String get reasonWalk;

  /// No description provided for @reasonSpeak.
  ///
  /// In en, this message translates to:
  /// **'Spoke your mind'**
  String get reasonSpeak;

  /// No description provided for @reasonSankalp.
  ///
  /// In en, this message translates to:
  /// **'Looked back on a Sankalp'**
  String get reasonSankalp;

  /// No description provided for @plusSemantic.
  ///
  /// In en, this message translates to:
  /// **'plus {n}'**
  String plusSemantic(int n);

  /// No description provided for @waitingSemantic.
  ///
  /// In en, this message translates to:
  /// **'{n} waiting'**
  String waitingSemantic(int n);

  /// No description provided for @todaysLightCaps.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S LIGHT'**
  String get todaysLightCaps;

  /// No description provided for @pointsToday.
  ///
  /// In en, this message translates to:
  /// **'Moksh Points today'**
  String get pointsToday;

  /// No description provided for @noMorePoints.
  ///
  /// In en, this message translates to:
  /// **'No more points today. Just peace.'**
  String get noMorePoints;

  /// No description provided for @oncePerDay.
  ///
  /// In en, this message translates to:
  /// **'Each step gives its points once a day.'**
  String get oncePerDay;

  /// No description provided for @yatraTitle.
  ///
  /// In en, this message translates to:
  /// **'Gita Yatra'**
  String get yatraTitle;

  /// No description provided for @yatraChapterOf.
  ///
  /// In en, this message translates to:
  /// **'Adhyaya {n} of 18'**
  String yatraChapterOf(int n);

  /// No description provided for @stoneToday.
  ///
  /// In en, this message translates to:
  /// **'Today: {yoga}, {id}'**
  String stoneToday(String yoga, String id);

  /// No description provided for @stoneN.
  ///
  /// In en, this message translates to:
  /// **'Stone {n}'**
  String stoneN(int n);

  /// No description provided for @stoneNCheckpoint.
  ///
  /// In en, this message translates to:
  /// **'Stone {n}, checkpoint'**
  String stoneNCheckpoint(int n);

  /// No description provided for @todayCaps.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayCaps;

  /// No description provided for @yogaAndId.
  ///
  /// In en, this message translates to:
  /// **'{yoga} · {id}'**
  String yogaAndId(String yoga, String id);

  /// No description provided for @intentionGrief.
  ///
  /// In en, this message translates to:
  /// **'Tell one person something you remember with love.'**
  String get intentionGrief;

  /// No description provided for @intentionLoss.
  ///
  /// In en, this message translates to:
  /// **'Keep one small thing that still connects you.'**
  String get intentionLoss;

  /// No description provided for @intentionFear.
  ///
  /// In en, this message translates to:
  /// **'Do the first small part of what you fear.'**
  String get intentionFear;

  /// No description provided for @intentionAnxiety.
  ///
  /// In en, this message translates to:
  /// **'Do one task fully, then let the result go.'**
  String get intentionAnxiety;

  /// No description provided for @intentionAnger.
  ///
  /// In en, this message translates to:
  /// **'Wait one breath before you answer today.'**
  String get intentionAnger;

  /// No description provided for @intentionEnvy.
  ///
  /// In en, this message translates to:
  /// **'Say one honest good word about someone else.'**
  String get intentionEnvy;

  /// No description provided for @intentionComparison.
  ///
  /// In en, this message translates to:
  /// **'Notice one thing you did well, without comparing.'**
  String get intentionComparison;

  /// No description provided for @intentionPride.
  ///
  /// In en, this message translates to:
  /// **'Ask one person for their advice today.'**
  String get intentionPride;

  /// No description provided for @intentionDesire.
  ///
  /// In en, this message translates to:
  /// **'Let one want pass without acting on it.'**
  String get intentionDesire;

  /// No description provided for @intentionGreed.
  ///
  /// In en, this message translates to:
  /// **'Give one thing away without counting it.'**
  String get intentionGreed;

  /// No description provided for @intentionRestlessness.
  ///
  /// In en, this message translates to:
  /// **'Sit still for two minutes before your phone.'**
  String get intentionRestlessness;

  /// No description provided for @intentionDoubt.
  ///
  /// In en, this message translates to:
  /// **'Take one step before you have every answer.'**
  String get intentionDoubt;

  /// No description provided for @intentionSelfDoubt.
  ///
  /// In en, this message translates to:
  /// **'Finish one small thing you said you would.'**
  String get intentionSelfDoubt;

  /// No description provided for @intentionConfusion.
  ///
  /// In en, this message translates to:
  /// **'Write down the one choice that matters today.'**
  String get intentionConfusion;

  /// No description provided for @intentionLoneliness.
  ///
  /// In en, this message translates to:
  /// **'Send one message to someone you miss.'**
  String get intentionLoneliness;

  /// No description provided for @intentionBurnout.
  ///
  /// In en, this message translates to:
  /// **'Rest for ten minutes without guilt.'**
  String get intentionBurnout;

  /// No description provided for @intentionFailure.
  ///
  /// In en, this message translates to:
  /// **'Try the thing once more, a little smaller.'**
  String get intentionFailure;

  /// No description provided for @intentionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank one person who helped you get here.'**
  String get intentionSuccess;

  /// No description provided for @intentionExamStress.
  ///
  /// In en, this message translates to:
  /// **'Study one topic fully, then close the book.'**
  String get intentionExamStress;

  /// No description provided for @intentionWorkPressure.
  ///
  /// In en, this message translates to:
  /// **'Do one task fully, without checking the result.'**
  String get intentionWorkPressure;

  /// No description provided for @intentionDutyConflict.
  ///
  /// In en, this message translates to:
  /// **'Do the duty in front of you, well.'**
  String get intentionDutyConflict;

  /// No description provided for @intentionProcrastination.
  ///
  /// In en, this message translates to:
  /// **'Start the task for five minutes only.'**
  String get intentionProcrastination;

  /// No description provided for @intentionPerfectionism.
  ///
  /// In en, this message translates to:
  /// **'Finish one thing and let it be enough.'**
  String get intentionPerfectionism;

  /// No description provided for @intentionFocus.
  ///
  /// In en, this message translates to:
  /// **'Do one thing at a time for an hour.'**
  String get intentionFocus;

  /// No description provided for @intentionDiscipline.
  ///
  /// In en, this message translates to:
  /// **'Keep one small promise to yourself.'**
  String get intentionDiscipline;

  /// No description provided for @intentionHabits.
  ///
  /// In en, this message translates to:
  /// **'Do the good habit once, at the same time.'**
  String get intentionHabits;

  /// No description provided for @intentionPatience.
  ///
  /// In en, this message translates to:
  /// **'Let one thing take the time it takes.'**
  String get intentionPatience;

  /// No description provided for @intentionEquanimity.
  ///
  /// In en, this message translates to:
  /// **'Meet one good and one hard moment the same.'**
  String get intentionEquanimity;

  /// No description provided for @intentionDetachment.
  ///
  /// In en, this message translates to:
  /// **'Do your best and leave the result.'**
  String get intentionDetachment;

  /// No description provided for @intentionForgiveness.
  ///
  /// In en, this message translates to:
  /// **'Let go of one old hurt, just for today.'**
  String get intentionForgiveness;

  /// No description provided for @intentionCompassion.
  ///
  /// In en, this message translates to:
  /// **'Do one quiet kindness no one will see.'**
  String get intentionCompassion;

  /// No description provided for @intentionKindness.
  ///
  /// In en, this message translates to:
  /// **'Do one quiet kindness no one will see.'**
  String get intentionKindness;

  /// No description provided for @intentionGratitude.
  ///
  /// In en, this message translates to:
  /// **'Name three things you are grateful for tonight.'**
  String get intentionGratitude;

  /// No description provided for @intentionHumility.
  ///
  /// In en, this message translates to:
  /// **'Listen fully before you speak, once today.'**
  String get intentionHumility;

  /// No description provided for @intentionFaith.
  ///
  /// In en, this message translates to:
  /// **'Begin your work with one quiet breath.'**
  String get intentionFaith;

  /// No description provided for @intentionSurrender.
  ///
  /// In en, this message translates to:
  /// **'Hand one worry over, and do your part.'**
  String get intentionSurrender;

  /// No description provided for @intentionPurpose.
  ///
  /// In en, this message translates to:
  /// **'Do one thing today that matters to you.'**
  String get intentionPurpose;

  /// No description provided for @intentionMortality.
  ///
  /// In en, this message translates to:
  /// **'Spend ten minutes on what truly matters.'**
  String get intentionMortality;

  /// No description provided for @intentionChange.
  ///
  /// In en, this message translates to:
  /// **'Welcome one small change without resisting.'**
  String get intentionChange;

  /// No description provided for @intentionSelfWorth.
  ///
  /// In en, this message translates to:
  /// **'Speak to yourself once as a friend would.'**
  String get intentionSelfWorth;

  /// No description provided for @intentionSpeech.
  ///
  /// In en, this message translates to:
  /// **'Say only what is true and kind today.'**
  String get intentionSpeech;

  /// No description provided for @intentionContentment.
  ///
  /// In en, this message translates to:
  /// **'Enjoy one simple thing without wanting more.'**
  String get intentionContentment;

  /// No description provided for @intentionPeace.
  ///
  /// In en, this message translates to:
  /// **'Put the phone down ten minutes before sleep.'**
  String get intentionPeace;

  /// No description provided for @intentionHope.
  ///
  /// In en, this message translates to:
  /// **'Do one small thing for tomorrow, tonight.'**
  String get intentionHope;

  /// No description provided for @intentionLearning.
  ///
  /// In en, this message translates to:
  /// **'Read one verse again, slowly.'**
  String get intentionLearning;

  /// No description provided for @intentionDefault.
  ///
  /// In en, this message translates to:
  /// **'Do one task fully, then let the result go.'**
  String get intentionDefault;

  /// No description provided for @wasAfraid.
  ///
  /// In en, this message translates to:
  /// **'who was afraid'**
  String get wasAfraid;

  /// No description provided for @wasGrieving.
  ///
  /// In en, this message translates to:
  /// **'who was grieving'**
  String get wasGrieving;

  /// No description provided for @wasLost.
  ///
  /// In en, this message translates to:
  /// **'who did not know what to do'**
  String get wasLost;

  /// No description provided for @wasDoubtful.
  ///
  /// In en, this message translates to:
  /// **'who was full of doubt'**
  String get wasDoubtful;

  /// No description provided for @wasTorn.
  ///
  /// In en, this message translates to:
  /// **'who was torn about his duty'**
  String get wasTorn;

  /// No description provided for @wasHeartLost.
  ///
  /// In en, this message translates to:
  /// **'who had lost heart'**
  String get wasHeartLost;

  /// No description provided for @toldPlain.
  ///
  /// In en, this message translates to:
  /// **'{speaker} told {listener}:'**
  String toldPlain(String speaker, String listener);

  /// No description provided for @toldWas.
  ///
  /// In en, this message translates to:
  /// **'{speaker} told {listener}, {was}:'**
  String toldWas(String speaker, String listener, String was);

  /// No description provided for @mannCaps.
  ///
  /// In en, this message translates to:
  /// **'MANN DARPAN'**
  String get mannCaps;

  /// No description provided for @mannAnswerTop.
  ///
  /// In en, this message translates to:
  /// **'A verse heard you'**
  String get mannAnswerTop;

  /// No description provided for @mannAskTonight.
  ///
  /// In en, this message translates to:
  /// **'How is your mind\ntonight?'**
  String get mannAskTonight;

  /// No description provided for @mannAskToday.
  ///
  /// In en, this message translates to:
  /// **'How is your mind\ntoday?'**
  String get mannAskToday;

  /// No description provided for @mannTapSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap, and speak for as long as you need.'**
  String get mannTapSpeak;

  /// No description provided for @typeInstead.
  ///
  /// In en, this message translates to:
  /// **'Type instead'**
  String get typeInstead;

  /// No description provided for @mannListening.
  ///
  /// In en, this message translates to:
  /// **'Listening.'**
  String get mannListening;

  /// No description provided for @mannSpeakPrivate.
  ///
  /// In en, this message translates to:
  /// **'Speak. Only you will hear this.'**
  String get mannSpeakPrivate;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @mannTypingTitle.
  ///
  /// In en, this message translates to:
  /// **'In a few words,\nwhat is on your mind?'**
  String get mannTypingTitle;

  /// No description provided for @hearYourself.
  ///
  /// In en, this message translates to:
  /// **'Hear yourself first'**
  String get hearYourself;

  /// No description provided for @mannHint.
  ///
  /// In en, this message translates to:
  /// **'I have an interview tomorrow and I keep thinking...'**
  String get mannHint;

  /// No description provided for @mannStays.
  ///
  /// In en, this message translates to:
  /// **'Stays on this phone. Nothing is sent anywhere.'**
  String get mannStays;

  /// No description provided for @letVerseAnswer.
  ///
  /// In en, this message translates to:
  /// **'Let a verse answer'**
  String get letVerseAnswer;

  /// No description provided for @intentTonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight: {text}'**
  String intentTonight(String text);

  /// No description provided for @intentToday.
  ///
  /// In en, this message translates to:
  /// **'Today: {text}'**
  String intentToday(String text);

  /// No description provided for @sealAsSankalp.
  ///
  /// In en, this message translates to:
  /// **'Seal as my Sankalp'**
  String get sealAsSankalp;

  /// No description provided for @notToday.
  ///
  /// In en, this message translates to:
  /// **'Not today'**
  String get notToday;

  /// No description provided for @mannOrbSemantic.
  ///
  /// In en, this message translates to:
  /// **'Speak. Tap to start.'**
  String get mannOrbSemantic;

  /// No description provided for @sealIt.
  ///
  /// In en, this message translates to:
  /// **'Seal it'**
  String get sealIt;

  /// No description provided for @sealedTitle.
  ///
  /// In en, this message translates to:
  /// **'Sealed.'**
  String get sealedTitle;

  /// No description provided for @lookBackTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Look back on it tomorrow.'**
  String get lookBackTomorrow;

  /// No description provided for @sealSankalpCaps.
  ///
  /// In en, this message translates to:
  /// **'SEAL A SANKALP'**
  String get sealSankalpCaps;

  /// No description provided for @oneSmallIntention.
  ///
  /// In en, this message translates to:
  /// **'One small intention.'**
  String get oneSmallIntention;

  /// No description provided for @fromGitaChange.
  ///
  /// In en, this message translates to:
  /// **'From Gita {id}. Change a word if you like.'**
  String fromGitaChange(String id);

  /// No description provided for @sealSankalpSemantic.
  ///
  /// In en, this message translates to:
  /// **'Seal this Sankalp'**
  String get sealSankalpSemantic;

  /// No description provided for @keptIt.
  ///
  /// In en, this message translates to:
  /// **'I kept it'**
  String get keptIt;

  /// No description provided for @letItGo.
  ///
  /// In en, this message translates to:
  /// **'I let it go'**
  String get letItGo;

  /// No description provided for @replyKept.
  ///
  /// In en, this message translates to:
  /// **'Kept. That is how a habit grows.'**
  String get replyKept;

  /// No description provided for @replyLetGo.
  ///
  /// In en, this message translates to:
  /// **'Let go. Today is a fresh start.'**
  String get replyLetGo;

  /// No description provided for @yourSankalpCaps.
  ///
  /// In en, this message translates to:
  /// **'YOUR SANKALP'**
  String get yourSankalpCaps;

  /// No description provided for @festival1.
  ///
  /// In en, this message translates to:
  /// **'Vasant Panchami'**
  String get festival1;

  /// No description provided for @festival2.
  ///
  /// In en, this message translates to:
  /// **'Maha Shivaratri'**
  String get festival2;

  /// No description provided for @festival3.
  ///
  /// In en, this message translates to:
  /// **'Holika Dahan'**
  String get festival3;

  /// No description provided for @festival4.
  ///
  /// In en, this message translates to:
  /// **'Ugadi and Gudi Padwa'**
  String get festival4;

  /// No description provided for @festival5.
  ///
  /// In en, this message translates to:
  /// **'Ram Navami'**
  String get festival5;

  /// No description provided for @festival6.
  ///
  /// In en, this message translates to:
  /// **'Hanuman Jayanti'**
  String get festival6;

  /// No description provided for @festival7.
  ///
  /// In en, this message translates to:
  /// **'Akshaya Tritiya'**
  String get festival7;

  /// No description provided for @festival8.
  ///
  /// In en, this message translates to:
  /// **'Rath Yatra'**
  String get festival8;

  /// No description provided for @festival9.
  ///
  /// In en, this message translates to:
  /// **'Guru Purnima'**
  String get festival9;

  /// No description provided for @festival10.
  ///
  /// In en, this message translates to:
  /// **'Raksha Bandhan'**
  String get festival10;

  /// No description provided for @festival11.
  ///
  /// In en, this message translates to:
  /// **'Janmashtami'**
  String get festival11;

  /// No description provided for @festival12.
  ///
  /// In en, this message translates to:
  /// **'Ganesh Chaturthi'**
  String get festival12;

  /// No description provided for @festival13.
  ///
  /// In en, this message translates to:
  /// **'Radha Ashtami'**
  String get festival13;

  /// No description provided for @festival14.
  ///
  /// In en, this message translates to:
  /// **'Anant Chaturdashi'**
  String get festival14;

  /// No description provided for @festival15.
  ///
  /// In en, this message translates to:
  /// **'Navratri begins'**
  String get festival15;

  /// No description provided for @festival16.
  ///
  /// In en, this message translates to:
  /// **'Durga Ashtami'**
  String get festival16;

  /// No description provided for @festival17.
  ///
  /// In en, this message translates to:
  /// **'Maha Navami'**
  String get festival17;

  /// No description provided for @festival18.
  ///
  /// In en, this message translates to:
  /// **'Vijayadashami'**
  String get festival18;

  /// No description provided for @festival19.
  ///
  /// In en, this message translates to:
  /// **'Sharad Purnima'**
  String get festival19;

  /// No description provided for @festival20.
  ///
  /// In en, this message translates to:
  /// **'Karva Chauth'**
  String get festival20;

  /// No description provided for @festival21.
  ///
  /// In en, this message translates to:
  /// **'Dhanteras'**
  String get festival21;

  /// No description provided for @festival22.
  ///
  /// In en, this message translates to:
  /// **'Naraka Chaturdashi'**
  String get festival22;

  /// No description provided for @festival23.
  ///
  /// In en, this message translates to:
  /// **'Diwali'**
  String get festival23;

  /// No description provided for @festival24.
  ///
  /// In en, this message translates to:
  /// **'Govardhan Puja'**
  String get festival24;

  /// No description provided for @festival25.
  ///
  /// In en, this message translates to:
  /// **'Bhai Dooj'**
  String get festival25;

  /// No description provided for @festival26.
  ///
  /// In en, this message translates to:
  /// **'Tulsi Vivah'**
  String get festival26;

  /// No description provided for @festival27.
  ///
  /// In en, this message translates to:
  /// **'Dev Deepawali'**
  String get festival27;

  /// No description provided for @festival28.
  ///
  /// In en, this message translates to:
  /// **'Makar Sankranti'**
  String get festival28;

  /// No description provided for @festival29.
  ///
  /// In en, this message translates to:
  /// **'Gita Jayanti'**
  String get festival29;

  /// No description provided for @festival30.
  ///
  /// In en, this message translates to:
  /// **'Holi'**
  String get festival30;

  /// No description provided for @festivalFallback.
  ///
  /// In en, this message translates to:
  /// **'Festival'**
  String get festivalFallback;

  /// No description provided for @weekday1.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekday1;

  /// No description provided for @weekday2.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekday2;

  /// No description provided for @weekday3.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekday3;

  /// No description provided for @weekday4.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekday4;

  /// No description provided for @weekday5.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekday5;

  /// No description provided for @weekday6.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekday6;

  /// No description provided for @weekday7.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekday7;

  /// No description provided for @weekdayShort1.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayShort1;

  /// No description provided for @weekdayShort2.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayShort2;

  /// No description provided for @weekdayShort3.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayShort3;

  /// No description provided for @weekdayShort4.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayShort4;

  /// No description provided for @weekdayShort5.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayShort5;

  /// No description provided for @weekdayShort6.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdayShort6;

  /// No description provided for @weekdayShort7.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdayShort7;

  /// No description provided for @dayTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dayTomorrow;

  /// No description provided for @whenOnDay.
  ///
  /// In en, this message translates to:
  /// **'on {day}'**
  String whenOnDay(String day);

  /// No description provided for @clockAt.
  ///
  /// In en, this message translates to:
  /// **'{period, select, nightEarly{{t} am} morning{{t} am} noon{{t} pm} evening{{t} pm} night{{t} pm} other{{t}}}'**
  String clockAt(String period, String t);

  /// No description provided for @ritualDailyGita.
  ///
  /// In en, this message translates to:
  /// **'Daily Gita'**
  String get ritualDailyGita;

  /// No description provided for @ritualSandhya.
  ///
  /// In en, this message translates to:
  /// **'Morning sandhya'**
  String get ritualSandhya;

  /// No description provided for @ritualDiya.
  ///
  /// In en, this message translates to:
  /// **'Evening diya'**
  String get ritualDiya;

  /// No description provided for @ritualEkadashi.
  ///
  /// In en, this message translates to:
  /// **'Ekadashi'**
  String get ritualEkadashi;

  /// No description provided for @ritualPurnima.
  ///
  /// In en, this message translates to:
  /// **'Purnima'**
  String get ritualPurnima;

  /// No description provided for @ritualAmavasya.
  ///
  /// In en, this message translates to:
  /// **'Amavasya'**
  String get ritualAmavasya;

  /// No description provided for @ritualPradosh.
  ///
  /// In en, this message translates to:
  /// **'Pradosh'**
  String get ritualPradosh;

  /// No description provided for @ritualSankashti.
  ///
  /// In en, this message translates to:
  /// **'Sankashti'**
  String get ritualSankashti;

  /// No description provided for @ritualFestivals.
  ///
  /// In en, this message translates to:
  /// **'Festivals'**
  String get ritualFestivals;

  /// No description provided for @meaningDailyGita.
  ///
  /// In en, this message translates to:
  /// **'Five verses from the Gita, at the hour you chose.'**
  String get meaningDailyGita;

  /// No description provided for @meaningSandhya.
  ///
  /// In en, this message translates to:
  /// **'A quiet minute to greet the sun as it rises.'**
  String get meaningSandhya;

  /// No description provided for @meaningDiya.
  ///
  /// In en, this message translates to:
  /// **'A soft reminder to light a lamp as the day ends.'**
  String get meaningDiya;

  /// No description provided for @meaningEkadashi.
  ///
  /// In en, this message translates to:
  /// **'Ekadashi is the eleventh day of the moon. Many people fast. We also tell you when to eat again. That is called parana.'**
  String get meaningEkadashi;

  /// No description provided for @meaningPurnima.
  ///
  /// In en, this message translates to:
  /// **'Purnima is the night the moon is full and round.'**
  String get meaningPurnima;

  /// No description provided for @meaningAmavasya.
  ///
  /// In en, this message translates to:
  /// **'Amavasya is the night with no moon. A time to remember family who came before.'**
  String get meaningAmavasya;

  /// No description provided for @meaningPradosh.
  ///
  /// In en, this message translates to:
  /// **'Pradosh is dusk on the thirteenth day of the moon, kept for Shiva.'**
  String get meaningPradosh;

  /// No description provided for @meaningSankashti.
  ///
  /// In en, this message translates to:
  /// **'Sankashti is a fast for Ganesha. It ends when the moon rises.'**
  String get meaningSankashti;

  /// No description provided for @meaningFestivals.
  ///
  /// In en, this message translates to:
  /// **'Big days like Diwali and Holi, on the right date for your city.'**
  String get meaningFestivals;

  /// No description provided for @deityNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get deityNone;

  /// No description provided for @deityShiva.
  ///
  /// In en, this message translates to:
  /// **'Shiva, Monday'**
  String get deityShiva;

  /// No description provided for @deityHanuman.
  ///
  /// In en, this message translates to:
  /// **'Hanuman, Tuesday'**
  String get deityHanuman;

  /// No description provided for @deityVishnu.
  ///
  /// In en, this message translates to:
  /// **'Vishnu or Guru, Thursday'**
  String get deityVishnu;

  /// No description provided for @deityShani.
  ///
  /// In en, this message translates to:
  /// **'Shani, Saturday'**
  String get deityShani;

  /// No description provided for @deityMeaningNone.
  ///
  /// In en, this message translates to:
  /// **'No special day for now.'**
  String get deityMeaningNone;

  /// No description provided for @deityMeaningShiva.
  ///
  /// In en, this message translates to:
  /// **'Monday is for Shiva. A lamp at sunset.'**
  String get deityMeaningShiva;

  /// No description provided for @deityMeaningHanuman.
  ///
  /// In en, this message translates to:
  /// **'Tuesday is for Hanuman. The Chalisa in the morning.'**
  String get deityMeaningHanuman;

  /// No description provided for @deityMeaningVishnu.
  ///
  /// In en, this message translates to:
  /// **'Thursday is for Vishnu, the teacher of teachers.'**
  String get deityMeaningVishnu;

  /// No description provided for @deityMeaningShani.
  ///
  /// In en, this message translates to:
  /// **'Saturday is for Shani. A quiet lamp at sunset.'**
  String get deityMeaningShani;

  /// No description provided for @noteGita.
  ///
  /// In en, this message translates to:
  /// **'Five verses are ready. Take your time.'**
  String get noteGita;

  /// No description provided for @noteSandhya.
  ///
  /// In en, this message translates to:
  /// **'Sunrise at {time}. A quiet minute for the morning sandhya, if you like.'**
  String noteSandhya(String time);

  /// No description provided for @noteDiya.
  ///
  /// In en, this message translates to:
  /// **'Sunset at {time}. The evening lamp, whenever you are ready.'**
  String noteDiya(String time);

  /// No description provided for @noteShiva.
  ///
  /// In en, this message translates to:
  /// **'Monday. A lamp for Shiva at sunset, {time}, if you like.'**
  String noteShiva(String time);

  /// No description provided for @noteHanuman.
  ///
  /// In en, this message translates to:
  /// **'Tuesday. The Chalisa this morning, if you like.'**
  String get noteHanuman;

  /// No description provided for @noteVishnu.
  ///
  /// In en, this message translates to:
  /// **'Thursday. A lamp for Vishnu at sunset, {time}, if you like.'**
  String noteVishnu(String time);

  /// No description provided for @noteShani.
  ///
  /// In en, this message translates to:
  /// **'Saturday. A quiet lamp at sunset, {time}, if you like.'**
  String noteShani(String time);

  /// No description provided for @notePurnima.
  ///
  /// In en, this message translates to:
  /// **'Purnima tonight. The full moon rises near sunset.'**
  String get notePurnima;

  /// No description provided for @noteAmavasya.
  ///
  /// In en, this message translates to:
  /// **'Amavasya today. A lamp for those who came before, if you like.'**
  String get noteAmavasya;

  /// No description provided for @notePradosh.
  ///
  /// In en, this message translates to:
  /// **'Pradosh today. Pradosh kaal {range}.'**
  String notePradosh(String range);

  /// No description provided for @noteSankashti.
  ///
  /// In en, this message translates to:
  /// **'Sankashti tonight. Moonrise {time}.'**
  String noteSankashti(String time);

  /// No description provided for @noteFestival.
  ///
  /// In en, this message translates to:
  /// **'{name} is today. A quiet, bright day to you.'**
  String noteFestival(String name);

  /// No description provided for @noteEkadashi.
  ///
  /// In en, this message translates to:
  /// **'Ekadashi{rule} begins at sunrise. Break the fast {when} {range}.'**
  String noteEkadashi(String rule, String when, String range);

  /// No description provided for @noteParana.
  ///
  /// In en, this message translates to:
  /// **'Parana window: {range}. Break the fast gently.'**
  String noteParana(String range);

  /// No description provided for @labelEkadashiRule.
  ///
  /// In en, this message translates to:
  /// **'Ekadashi ({rule})'**
  String labelEkadashiRule(String rule);

  /// No description provided for @labelParana.
  ///
  /// In en, this message translates to:
  /// **'Parana {range}'**
  String labelParana(String range);

  /// No description provided for @labelPradosh.
  ///
  /// In en, this message translates to:
  /// **'Pradosh {range}'**
  String labelPradosh(String range);

  /// No description provided for @ruleSuffix.
  ///
  /// In en, this message translates to:
  /// **' ({rule})'**
  String ruleSuffix(String rule);

  /// No description provided for @notifChannel.
  ///
  /// In en, this message translates to:
  /// **'Ritual reminders'**
  String get notifChannel;

  /// No description provided for @notifChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Quiet reminders for the rituals you chose.'**
  String get notifChannelDesc;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Your practice'**
  String get practiceTitle;

  /// No description provided for @practiceRebuild.
  ///
  /// In en, this message translates to:
  /// **'Build my practice again'**
  String get practiceRebuild;

  /// No description provided for @allReminders.
  ///
  /// In en, this message translates to:
  /// **'All reminders'**
  String get allReminders;

  /// No description provided for @nextNote.
  ///
  /// In en, this message translates to:
  /// **'Next: {when}'**
  String nextNote(String when);

  /// No description provided for @changeHour.
  ///
  /// In en, this message translates to:
  /// **'Change the hour'**
  String get changeHour;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn this off'**
  String get turnOff;

  /// No description provided for @practiceIntro.
  ///
  /// In en, this message translates to:
  /// **'What we remind you of, and when. Tap one to see what it means.'**
  String get practiceIntro;

  /// No description provided for @nothingOn.
  ///
  /// In en, this message translates to:
  /// **'Nothing is on yet.'**
  String get nothingOn;

  /// No description provided for @allRemindersWhy.
  ///
  /// In en, this message translates to:
  /// **'Every switch, one by one. For when you know just what you want.'**
  String get allRemindersWhy;

  /// No description provided for @hourSheetWhy.
  ///
  /// In en, this message translates to:
  /// **'Your five verses wait for you at this hour.'**
  String get hourSheetWhy;

  /// No description provided for @verseHour.
  ///
  /// In en, this message translates to:
  /// **'Verse hour'**
  String get verseHour;

  /// No description provided for @weekdayLamp.
  ///
  /// In en, this message translates to:
  /// **'A weekday lamp'**
  String get weekdayLamp;

  /// No description provided for @savePractice.
  ///
  /// In en, this message translates to:
  /// **'Save my practice'**
  String get savePractice;

  /// No description provided for @itemAtTime.
  ///
  /// In en, this message translates to:
  /// **'{label}, {time}'**
  String itemAtTime(String label, String time);

  /// No description provided for @ritualSemantic.
  ///
  /// In en, this message translates to:
  /// **'{label}. {meaning}'**
  String ritualSemantic(String label, String meaning);

  /// No description provided for @traditionCaps.
  ///
  /// In en, this message translates to:
  /// **'SMARTA AND VAISHNAVA'**
  String get traditionCaps;

  /// No description provided for @traditionExplTitle.
  ///
  /// In en, this message translates to:
  /// **'Two ways to keep Ekadashi'**
  String get traditionExplTitle;

  /// No description provided for @traditionTithi.
  ///
  /// In en, this message translates to:
  /// **'The moon has its own days. Each one is called a tithi. A tithi does not start at midnight. It can start at any hour.'**
  String get traditionTithi;

  /// No description provided for @traditionEkadashi.
  ///
  /// In en, this message translates to:
  /// **'Ekadashi is the eleventh tithi. Dashami, the tenth, comes just before it.'**
  String get traditionEkadashi;

  /// No description provided for @traditionSmartaRule.
  ///
  /// In en, this message translates to:
  /// **'Fast on the day Ekadashi is there when the sun rises.'**
  String get traditionSmartaRule;

  /// No description provided for @traditionVaishnavaRule.
  ///
  /// In en, this message translates to:
  /// **'Ekadashi must be clean from dawn, about an hour and a half before sunrise. If Dashami is still there at dawn, fast the next day.'**
  String get traditionVaishnavaRule;

  /// No description provided for @traditionSame.
  ///
  /// In en, this message translates to:
  /// **'Most months, both fall on the same day.'**
  String get traditionSame;

  /// No description provided for @traditionUnsureLine.
  ///
  /// In en, this message translates to:
  /// **'Not sure? Follow what your family does. You can change this later.'**
  String get traditionUnsureLine;

  /// No description provided for @traditionRare.
  ///
  /// In en, this message translates to:
  /// **'In a few months the moon moves fast and other rules decide. Our dates match Drik Panchang where we checked.'**
  String get traditionRare;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @timelineSemantic.
  ///
  /// In en, this message translates to:
  /// **'Two sunrises. Dashami ends after dawn on day 1. The Smarta lamp stays on day 1. The Vaishnava lamp moves to day 2.'**
  String get timelineSemantic;

  /// No description provided for @tlDashami.
  ///
  /// In en, this message translates to:
  /// **'DASHAMI'**
  String get tlDashami;

  /// No description provided for @tlEkadashi.
  ///
  /// In en, this message translates to:
  /// **'EKADASHI'**
  String get tlEkadashi;

  /// No description provided for @tlDvadashi.
  ///
  /// In en, this message translates to:
  /// **'DVADASHI'**
  String get tlDvadashi;

  /// No description provided for @tlDay1.
  ///
  /// In en, this message translates to:
  /// **'DAY 1'**
  String get tlDay1;

  /// No description provided for @tlDay2.
  ///
  /// In en, this message translates to:
  /// **'DAY 2'**
  String get tlDay2;

  /// No description provided for @tlDawn.
  ///
  /// In en, this message translates to:
  /// **'DAWN'**
  String get tlDawn;

  /// No description provided for @tlSmarta.
  ///
  /// In en, this message translates to:
  /// **'SMARTA'**
  String get tlSmarta;

  /// No description provided for @tlVaishnava.
  ///
  /// In en, this message translates to:
  /// **'VAISHNAVA'**
  String get tlVaishnava;

  /// No description provided for @clockRange.
  ///
  /// In en, this message translates to:
  /// **'{same, select, yes{{aBare}-{bFull}} other{{aFull}-{bFull}}}'**
  String clockRange(String same, String aBare, String aFull, String bFull);

  /// No description provided for @nameLead.
  ///
  /// In en, this message translates to:
  /// **'{name}.  '**
  String nameLead(String name);

  /// No description provided for @crisisTitle.
  ///
  /// In en, this message translates to:
  /// **'You don’t have to carry this alone.'**
  String get crisisTitle;

  /// No description provided for @crisisBody.
  ///
  /// In en, this message translates to:
  /// **'What you shared sounds very heavy. A trained person can help right now.'**
  String get crisisBody;

  /// No description provided for @crisisCall.
  ///
  /// In en, this message translates to:
  /// **'Call Tele-MANAS 14416'**
  String get crisisCall;

  /// No description provided for @crisisDialFallback.
  ///
  /// In en, this message translates to:
  /// **'Dial 14416 or 1-800-891-4416 from your phone.'**
  String get crisisDialFallback;

  /// No description provided for @crisisFree.
  ///
  /// In en, this message translates to:
  /// **'Free, any time, in many languages. Also 1-800-891-4416.'**
  String get crisisFree;

  /// No description provided for @crisisEmergency.
  ///
  /// In en, this message translates to:
  /// **'Call 112 if you are in danger now'**
  String get crisisEmergency;

  /// No description provided for @crisisEmergencyFallback.
  ///
  /// In en, this message translates to:
  /// **'Dial 112 from your phone.'**
  String get crisisEmergencyFallback;

  /// No description provided for @crisisMessage.
  ///
  /// In en, this message translates to:
  /// **'Message someone I trust'**
  String get crisisMessage;

  /// No description provided for @crisisSmsBody.
  ///
  /// In en, this message translates to:
  /// **'Can you call me? I’m having a hard time.'**
  String get crisisSmsBody;

  /// No description provided for @crisisSmsFallback.
  ///
  /// In en, this message translates to:
  /// **'Send someone you trust: “{text}”'**
  String crisisSmsFallback(String text);

  /// No description provided for @crisisBreathe.
  ///
  /// In en, this message translates to:
  /// **'Stay here and breathe'**
  String get crisisBreathe;

  /// No description provided for @crisisNothingKept.
  ///
  /// In en, this message translates to:
  /// **'Nothing you wrote was kept. No points, no record.'**
  String get crisisNothingKept;

  /// No description provided for @breatheSemantic.
  ///
  /// In en, this message translates to:
  /// **'Breathe in for 4 seconds, and out for 6.'**
  String get breatheSemantic;

  /// No description provided for @breatheStill.
  ///
  /// In en, this message translates to:
  /// **'In for 4. Out for 6.'**
  String get breatheStill;

  /// No description provided for @breatheIn.
  ///
  /// In en, this message translates to:
  /// **'Breathe in'**
  String get breatheIn;

  /// No description provided for @breatheOut.
  ///
  /// In en, this message translates to:
  /// **'Breathe out'**
  String get breatheOut;

  /// No description provided for @authShortNumber.
  ///
  /// In en, this message translates to:
  /// **'That number looks too short.'**
  String get authShortNumber;

  /// No description provided for @authShortCode.
  ///
  /// In en, this message translates to:
  /// **'The code has six numbers.'**
  String get authShortCode;

  /// No description provided for @authSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Sign in first.'**
  String get authSignInFirst;

  /// No description provided for @friendName.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get friendName;

  /// No description provided for @ekWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get ekWrite;

  /// No description provided for @ekSpeak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get ekSpeak;

  /// No description provided for @ekDoorPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your words stay on this phone. Let them fade when you are done, or keep them.'**
  String get ekDoorPrivacy;

  /// No description provided for @ekDoorWaiting.
  ///
  /// In en, this message translates to:
  /// **'Your last conversation is still here.'**
  String get ekDoorWaiting;

  /// No description provided for @ekSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get ekSend;

  /// No description provided for @ekWriteHint.
  ///
  /// In en, this message translates to:
  /// **'Write here'**
  String get ekWriteHint;

  /// No description provided for @ekAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Answer, or say more'**
  String get ekAnswerHint;

  /// No description provided for @ekYouSaid.
  ///
  /// In en, this message translates to:
  /// **'You said'**
  String get ekYouSaid;

  /// No description provided for @ekEkantSaid.
  ///
  /// In en, this message translates to:
  /// **'Ekant'**
  String get ekEkantSaid;

  /// No description provided for @ekReflecting.
  ///
  /// In en, this message translates to:
  /// **'Ekant is reflecting'**
  String get ekReflecting;

  /// No description provided for @ekCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get ekCopy;

  /// No description provided for @ekCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get ekCopied;

  /// No description provided for @ekStudy.
  ///
  /// In en, this message translates to:
  /// **'Read this verse'**
  String get ekStudy;

  /// No description provided for @ekFailedNote.
  ///
  /// In en, this message translates to:
  /// **'The room went quiet. Please try again.'**
  String get ekFailedNote;

  /// No description provided for @ekShareFooter.
  ///
  /// In en, this message translates to:
  /// **'From Ekant, in DharmaScroll'**
  String get ekShareFooter;

  /// No description provided for @ekOpen1.
  ///
  /// In en, this message translates to:
  /// **'Work has been weighing on me.'**
  String get ekOpen1;

  /// No description provided for @ekOpen2.
  ///
  /// In en, this message translates to:
  /// **'I cannot stop worrying.'**
  String get ekOpen2;

  /// No description provided for @ekOpen3.
  ///
  /// In en, this message translates to:
  /// **'I feel alone today.'**
  String get ekOpen3;

  /// No description provided for @ekOpen4.
  ///
  /// In en, this message translates to:
  /// **'I am angry and cannot let it go.'**
  String get ekOpen4;

  /// No description provided for @ekConnecting.
  ///
  /// In en, this message translates to:
  /// **'Getting ready'**
  String get ekConnecting;

  /// No description provided for @ekIdle.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ekIdle;

  /// No description provided for @ekListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get ekListening;

  /// No description provided for @ekThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get ekThinking;

  /// No description provided for @ekSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get ekSpeaking;

  /// No description provided for @ekMuted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get ekMuted;

  /// No description provided for @ekConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect'**
  String get ekConnectFailed;

  /// No description provided for @ekMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get ekMute;

  /// No description provided for @ekUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get ekUnmute;

  /// No description provided for @ekEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get ekEnd;

  /// No description provided for @ekSwitchToChat.
  ///
  /// In en, this message translates to:
  /// **'Switch to chat'**
  String get ekSwitchToChat;

  /// No description provided for @ekHandsFree.
  ///
  /// In en, this message translates to:
  /// **'Hands-free'**
  String get ekHandsFree;

  /// No description provided for @ekPushToTalk.
  ///
  /// In en, this message translates to:
  /// **'Push to talk'**
  String get ekPushToTalk;

  /// No description provided for @ekHoldToTalk.
  ///
  /// In en, this message translates to:
  /// **'Hold to talk'**
  String get ekHoldToTalk;

  /// No description provided for @ekRelease.
  ///
  /// In en, this message translates to:
  /// **'Release when done'**
  String get ekRelease;

  /// No description provided for @ekYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get ekYou;

  /// No description provided for @ekCaptionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Words appear here as you speak.'**
  String get ekCaptionsEmpty;

  /// No description provided for @ekRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get ekRetry;

  /// No description provided for @ekMicTitle.
  ///
  /// In en, this message translates to:
  /// **'Use your microphone?'**
  String get ekMicTitle;

  /// No description provided for @ekMicBody.
  ///
  /// In en, this message translates to:
  /// **'To talk, the phone needs to hear you. Sound is only used while this room is open. The room shows your words as you speak.'**
  String get ekMicBody;

  /// No description provided for @ekMicAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone'**
  String get ekMicAllow;

  /// No description provided for @ekMicDenied.
  ///
  /// In en, this message translates to:
  /// **'The microphone is off. You can allow it in the phone settings, or write instead.'**
  String get ekMicDenied;

  /// No description provided for @ekPrompt.
  ///
  /// In en, this message translates to:
  /// **'What is on your mind?'**
  String get ekPrompt;

  /// No description provided for @ekRest.
  ///
  /// In en, this message translates to:
  /// **'Rest now'**
  String get ekRest;

  /// No description provided for @ekFade.
  ///
  /// In en, this message translates to:
  /// **'Let it fade'**
  String get ekFade;

  /// No description provided for @ekKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep on this phone'**
  String get ekKeep;

  /// No description provided for @ekReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get ekReturn;

  /// No description provided for @ekEnough.
  ///
  /// In en, this message translates to:
  /// **'That is enough for this sitting.'**
  String get ekEnough;

  /// No description provided for @ekKeepFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not keep it on this phone. Try again.'**
  String get ekKeepFailed;

  /// No description provided for @ekLeaveRoom.
  ///
  /// In en, this message translates to:
  /// **'Leave the room'**
  String get ekLeaveRoom;

  /// No description provided for @ekLeaveCaps.
  ///
  /// In en, this message translates to:
  /// **'LEAVE'**
  String get ekLeaveCaps;

  /// No description provided for @ekQuietRoom.
  ///
  /// In en, this message translates to:
  /// **'A quiet room.'**
  String get ekQuietRoom;

  /// No description provided for @ekNoOne.
  ///
  /// In en, this message translates to:
  /// **'No one is here. The app finds a verse of the Gita. Only the verse is the Gita’s word.'**
  String get ekNoOne;

  /// No description provided for @ekDanger.
  ///
  /// In en, this message translates to:
  /// **'In danger? Call 112. Tele-MANAS 14416 is free, any time.'**
  String get ekDanger;

  /// No description provided for @ekKeptNotesBtn.
  ///
  /// In en, this message translates to:
  /// **'Kept notes ({n})'**
  String ekKeptNotesBtn(int n);

  /// No description provided for @ekVerseToCarry.
  ///
  /// In en, this message translates to:
  /// **'A verse to carry'**
  String get ekVerseToCarry;

  /// No description provided for @ekYourWords.
  ///
  /// In en, this message translates to:
  /// **'Your words'**
  String get ekYourWords;

  /// No description provided for @ekRestNow.
  ///
  /// In en, this message translates to:
  /// **'Rest now.'**
  String get ekRestNow;

  /// No description provided for @ekKeptOnly.
  ///
  /// In en, this message translates to:
  /// **'Kept on this phone only. The verse stays.'**
  String get ekKeptOnly;

  /// No description provided for @ekGone.
  ///
  /// In en, this message translates to:
  /// **'Your words have gone. The verse stays.'**
  String get ekGone;

  /// No description provided for @ekVerseSemantic.
  ///
  /// In en, this message translates to:
  /// **'{attribution} Gita chapter {chapter}, verse {number}. {meaning}'**
  String ekVerseSemantic(
    String attribution,
    int chapter,
    int number,
    String meaning,
  );

  /// No description provided for @ekVerseCardSemantic.
  ///
  /// In en, this message translates to:
  /// **'Gita chapter {chapter}, verse {number}. {meaning}. {study}'**
  String ekVerseCardSemantic(
    int chapter,
    int number,
    String meaning,
    String study,
  );

  /// No description provided for @ekGitaStudy.
  ///
  /// In en, this message translates to:
  /// **'Gita {id}. {study}'**
  String ekGitaStudy(String id, String study);

  /// No description provided for @ekGitaStudyCaps.
  ///
  /// In en, this message translates to:
  /// **'GITA {id}  ·  {study}'**
  String ekGitaStudyCaps(String id, String study);

  /// No description provided for @ekKeptNotes.
  ///
  /// In en, this message translates to:
  /// **'Kept notes'**
  String get ekKeptNotes;

  /// No description provided for @ekKeptNotesWhy.
  ///
  /// In en, this message translates to:
  /// **'On this phone only, encrypted.'**
  String get ekKeptNotesWhy;

  /// No description provided for @ekDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get ekDelete;

  /// No description provided for @ekNoteHead.
  ///
  /// In en, this message translates to:
  /// **'{date}  ·  GITA {id}'**
  String ekNoteHead(String date, String id);

  /// No description provided for @ekVoiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice is not available here. Typing works.'**
  String get ekVoiceUnavailable;

  /// No description provided for @ekTalkOutLoud.
  ///
  /// In en, this message translates to:
  /// **'Talk to Ekant out loud'**
  String get ekTalkOutLoud;

  /// No description provided for @ekWriteIntro.
  ///
  /// In en, this message translates to:
  /// **'Write it as it comes. Hindi, English or Hinglish.'**
  String get ekWriteIntro;

  /// No description provided for @ekDictate.
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get ekDictate;

  /// No description provided for @exSimpleLabel.
  ///
  /// In en, this message translates to:
  /// **'In simple words'**
  String get exSimpleLabel;

  /// No description provided for @exSimpleHead.
  ///
  /// In en, this message translates to:
  /// **'What it means'**
  String get exSimpleHead;

  /// No description provided for @exWordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Word by word'**
  String get exWordsLabel;

  /// No description provided for @exWordsHead.
  ///
  /// In en, this message translates to:
  /// **'One word at a time'**
  String get exWordsHead;

  /// No description provided for @exMomentLabel.
  ///
  /// In en, this message translates to:
  /// **'The moment'**
  String get exMomentLabel;

  /// No description provided for @exMomentHead.
  ///
  /// In en, this message translates to:
  /// **'Kurukshetra, at dawn'**
  String get exMomentHead;

  /// No description provided for @exRelatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Related verses'**
  String get exRelatedLabel;

  /// No description provided for @exRelatedHead.
  ///
  /// In en, this message translates to:
  /// **'On the same path'**
  String get exRelatedHead;

  /// No description provided for @exMyDayLabel.
  ///
  /// In en, this message translates to:
  /// **'For my day'**
  String get exMyDayLabel;

  /// No description provided for @exMyDayHead.
  ///
  /// In en, this message translates to:
  /// **'One line from you'**
  String get exMyDayHead;

  /// No description provided for @exDraftNote.
  ///
  /// In en, this message translates to:
  /// **'Written for this app. Draft, pending scholar review.'**
  String get exDraftNote;

  /// No description provided for @exOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'Replies written with AI are coming. For now the verse answers from your phone.'**
  String get exOfflineNote;

  /// No description provided for @exAskHint.
  ///
  /// In en, this message translates to:
  /// **'What is on your mind today?'**
  String get exAskHint;

  /// No description provided for @exAskLabel.
  ///
  /// In en, this message translates to:
  /// **'Show me'**
  String get exAskLabel;

  /// No description provided for @exBackTo.
  ///
  /// In en, this message translates to:
  /// **'Back to Gita {id}'**
  String exBackTo(String id);

  /// No description provided for @exVerseSemantic.
  ///
  /// In en, this message translates to:
  /// **'Verse {id}. {sanskrit}'**
  String exVerseSemantic(String id, String sanskrit);

  /// No description provided for @exListen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get exListen;

  /// No description provided for @exListenHint.
  ///
  /// In en, this message translates to:
  /// **'Press and hold to listen'**
  String get exListenHint;

  /// No description provided for @exWordsNote.
  ///
  /// In en, this message translates to:
  /// **'Word meanings in English. Draft, pending scholar review.'**
  String get exWordsNote;

  /// No description provided for @exSpeaksTo.
  ///
  /// In en, this message translates to:
  /// **'{speaker} speaks to {listener}.'**
  String exSpeaksTo(String speaker, String listener);

  /// No description provided for @exChapterHead.
  ///
  /// In en, this message translates to:
  /// **'ADHYAY {chapter} · {yoga}'**
  String exChapterHead(int chapter, String yoga);

  /// No description provided for @exOpenGita.
  ///
  /// In en, this message translates to:
  /// **'Open Gita {id}'**
  String exOpenGita(String id);

  /// No description provided for @exOfflineCaps.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE · FROM YOUR PHONE'**
  String get exOfflineCaps;

  /// No description provided for @exBusy.
  ///
  /// In en, this message translates to:
  /// **'Listening to the verse'**
  String get exBusy;

  /// No description provided for @exBySoftware.
  ///
  /// In en, this message translates to:
  /// **'Written by software, from the verse.'**
  String get exBySoftware;

  /// No description provided for @exFromPhone.
  ///
  /// In en, this message translates to:
  /// **'From your phone. Not a teacher or a counsellor.'**
  String get exFromPhone;

  /// No description provided for @exStoryOnly.
  ///
  /// In en, this message translates to:
  /// **'This verse is part of the story, not advice for your day. This one may sit closer to you.'**
  String get exStoryOnly;

  /// No description provided for @exSaid.
  ///
  /// In en, this message translates to:
  /// **'{speaker} told {listener} this for moments of {situations}.'**
  String exSaid(String speaker, String listener, String situations);

  /// No description provided for @exListAnd.
  ///
  /// In en, this message translates to:
  /// **'{rest} and {last}'**
  String exListAnd(String rest, String last);

  /// No description provided for @exCarry.
  ///
  /// In en, this message translates to:
  /// **'{said} Carry one line of it with you today.'**
  String exCarry(String said);

  /// No description provided for @exMeets.
  ///
  /// In en, this message translates to:
  /// **'{said} It meets the {tag} you wrote about. Read it once more, slowly.'**
  String exMeets(String said, String tag);

  /// No description provided for @exCloser.
  ///
  /// In en, this message translates to:
  /// **'{said} For {tag}, Gita {id} may sit closer.'**
  String exCloser(String said, String tag, String id);

  /// No description provided for @exHold.
  ///
  /// In en, this message translates to:
  /// **'{said} Hold your day up to it and see what stays.'**
  String exHold(String said);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
