import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prefs are loaded once in `main` and injected, so the first frame never waits
/// on a plugin and the router can read onboarding state synchronously.
final Provider<SharedPreferences> sharedPrefsProvider =
    Provider<SharedPreferences>((Ref ref) {
      throw UnimplementedError(
        'sharedPrefsProvider must be overridden in main()',
      );
    });

/// Local time source. Tests override it to pin the hour and the day.
final Provider<DateTime Function()> clockProvider =
    Provider<DateTime Function()>((Ref ref) => DateTime.now);
