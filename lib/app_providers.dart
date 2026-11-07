import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/models/verse.dart';

/// Prefs are loaded once in `main` and injected, so the first frame never waits
/// on a plugin and the router can read onboarding state synchronously.
final Provider<SharedPreferences> sharedPrefsProvider =
    Provider<SharedPreferences>((Ref ref) {
      throw UnimplementedError(
        'sharedPrefsProvider must be overridden in main()',
      );
    });

final Provider<List<Verse>> verseCatalogProvider = Provider<List<Verse>>((
  Ref ref,
) {
  // Replaced by the asset-backed repository once gita_seed.json lands.
  return const <Verse>[];
});
