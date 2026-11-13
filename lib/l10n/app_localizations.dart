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
