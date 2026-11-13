import 'package:dharmascroll/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:dharmascroll/l10n/auth_words.dart';
export 'package:dharmascroll/l10n/l10n.dart';
export 'package:dharmascroll/l10n/ritual_words.dart';

/// The app's English words, for tests that look for text on screen.
final AppLocalizations en = lookupAppLocalizations(const Locale('en'));

/// The same in Hindi.
final AppLocalizations hi = lookupAppLocalizations(const Locale('hi'));
