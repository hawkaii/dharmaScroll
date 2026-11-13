import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nX on BuildContext {
  /// The app's words in the chosen language.
  AppLocalizations get l => AppLocalizations.of(this);
}
