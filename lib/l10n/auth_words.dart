import '../core/auth/auth_service.dart';
import 'app_localizations.dart';

/// Sign-in words, in the chosen language.
extension AuthWords on AppLocalizations {
  /// What went wrong, in words the person can act on.
  String authProblem(AuthProblem p) => switch (p) {
    AuthProblem.shortNumber => authShortNumber,
    AuthProblem.shortCode => authShortCode,
    AuthProblem.signInFirst => authSignInFirst,
  };

  /// The name to greet: the placeholder name the fake sign-in saves reads as
  /// "Friend" (or its Hindi) in the chosen language.
  String greetingName(String name) => name == kPlaceholderName ? friendName : name;
}
