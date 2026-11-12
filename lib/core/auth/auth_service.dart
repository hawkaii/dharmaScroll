import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_providers.dart';

enum SignInMethod { guest, google, phone }

/// Who is using the app. Lives on this phone only, for now.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.method,
    this.phone,
  });

  final String id;
  final String name;
  final SignInMethod method;
  final String? phone;

  bool get isGuest => method == SignInMethod.guest;

  AuthUser copyWith({String? name}) =>
      AuthUser(id: id, name: name ?? this.name, method: method, phone: phone);

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'method': method.name,
    'phone': phone,
  };

  static AuthUser? fromJson(Object? j) {
    if (j is! Map<String, Object?>) return null;
    final SignInMethod? m = SignInMethod.values
        .where((SignInMethod x) => x.name == j['method'])
        .firstOrNull;
    final Object? id = j['id'];
    final Object? name = j['name'];
    if (m == null || id is! String || name is! String) return null;
    final Object? phone = j['phone'];
    return AuthUser(
      id: id,
      name: name,
      method: m,
      phone: phone is String ? phone : null,
    );
  }
}

/// A sign-in step failed in a way the person can fix (a short code, say).
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The seam for real sign-in. The app talks only to this.
///
/// To plug in real providers, implement this interface and override
/// [authServiceProvider] in `main.dart`:
/// - [signInWithGoogle]: Google OAuth (for example `google_sign_in`, or
///   Firebase Auth's Google provider).
/// - [sendCode] / [verifyCode]: phone OTP (for example Firebase Auth
///   `verifyPhoneNumber`, or an SMS provider behind your own server).
abstract interface class AuthService {
  AuthUser? get current;
  Future<AuthUser> signInWithGoogle();

  /// Sends a one-time code by SMS. [phone] has digits only, with country code.
  Future<void> sendCode(String phone);
  Future<AuthUser> verifyCode(String phone, String code);
  Future<AuthUser> continueAsGuest();
  Future<AuthUser> rename(String name);
  Future<void> signOut();
}

/// No network: every sign-in is pretend and is stored on this phone.
/// Google always "succeeds"; any 6-digit code "verifies".
class FakeAuthService implements AuthService {
  FakeAuthService(this._prefs);

  static const String kUser = 'authUser';
  final SharedPreferences _prefs;

  @override
  AuthUser? get current {
    final String? raw = _prefs.getString(kUser);
    if (raw == null) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  Future<AuthUser> _save(AuthUser u) async {
    await _prefs.setString(kUser, jsonEncode(u.toJson()));
    return u;
  }

  String _id() => 'local-${DateTime.now().microsecondsSinceEpoch}';

  @override
  Future<AuthUser> signInWithGoogle() async {
    // OAuth plugs in here: real name and id come from the Google account.
    return _save(
      AuthUser(id: _id(), name: 'Friend', method: SignInMethod.google),
    );
  }

  @override
  Future<void> sendCode(String phone) async {
    // OTP plugs in here: ask the provider to text the code.
    if (phone.length < 8 || phone.length > 15) {
      throw const AuthException('That number looks too short.');
    }
  }

  @override
  Future<AuthUser> verifyCode(String phone, String code) async {
    // OTP plugs in here: the provider checks the code.
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      throw const AuthException('The code has six numbers.');
    }
    return _save(
      AuthUser(
        id: _id(),
        name: 'Friend',
        method: SignInMethod.phone,
        phone: phone,
      ),
    );
  }

  @override
  Future<AuthUser> continueAsGuest() =>
      _save(AuthUser(id: _id(), name: '', method: SignInMethod.guest));

  @override
  Future<AuthUser> rename(String name) async {
    final AuthUser? u = current;
    if (u == null) throw const AuthException('Sign in first.');
    return _save(u.copyWith(name: name.trim()));
  }

  @override
  Future<void> signOut() => _prefs.remove(kUser);
}

final Provider<AuthService> authServiceProvider = Provider<AuthService>(
  (Ref ref) => FakeAuthService(ref.watch(sharedPrefsProvider)),
);

/// The person signed in, or null. Signing out keeps all progress.
class AuthNotifier extends Notifier<AuthUser?> {
  AuthService get _s => ref.read(authServiceProvider);

  @override
  AuthUser? build() => ref.watch(authServiceProvider).current;

  Future<void> google() async => state = await _s.signInWithGoogle();
  Future<void> sendCode(String phone) => _s.sendCode(phone);
  Future<void> verify(String phone, String code) async =>
      state = await _s.verifyCode(phone, code);
  Future<void> guest() async => state = await _s.continueAsGuest();
  Future<void> rename(String name) async => state = await _s.rename(name);
  Future<void> signOut() async {
    await _s.signOut();
    state = null;
  }
}

final NotifierProvider<AuthNotifier, AuthUser?> authProvider =
    NotifierProvider<AuthNotifier, AuthUser?>(AuthNotifier.new);
