import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local-only authentication for the offline-first app. There is no backend,
/// so a single business account is stored on-device in Hive: a salted hash
/// of the password (never the plaintext) plus a "logged in" flag that lets
/// returning users skip straight to the dashboard.
///
/// This intentionally mirrors [LocalStore]'s style (a thin wrapper over a
/// Hive box of plain values) so it needs no generated adapters.
class AuthService {
  static const _boxName = 'auth_box';
  static const _keyEmail = 'email';
  static const _keySalt = 'salt';
  static const _keyHash = 'password_hash';
  static const _keyLoggedIn = 'logged_in';

  Box? _box;

  Future<void> init() async {
    // Safe to call even if Hive.initFlutter() already ran for LocalStore.
    // If Hive has already been pointed at a storage directory (e.g. by a
    // test calling Hive.init() directly, since initFlutter() needs a
    // platform channel that isn't available in the test environment), this
    // is a harmless no-op rather than a fatal error.
    try {
      await Hive.initFlutter();
    } catch (_) {
      // Fall through and rely on whatever Hive.init() already configured.
    }
    _box = await Hive.openBox(_boxName);
  }

  /// Whether a business account has already been created on this device.
  bool get hasAccount => _box?.get(_keyEmail) != null;

  /// Whether the current session is authenticated (persisted across app
  /// restarts until [logout] is called).
  bool get isLoggedIn => _box?.get(_keyLoggedIn, defaultValue: false) as bool? ?? false;

  String? get currentEmail => _box?.get(_keyEmail) as String?;

  String _generateSalt() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hash(String password, String salt) {
    final digest = sha256.convert(utf8.encode('$salt:$password'));
    return digest.toString();
  }

  /// Creates the local account, storing only a salted hash of [password].
  /// Marks the session as logged in on success.
  Future<AuthResult> signUp({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return AuthResult.failure('Enter a valid business email address.');
    }
    if (password.length < 6) {
      return AuthResult.failure('Password must be at least 6 characters.');
    }
    final box = _box;
    if (box == null) return AuthResult.failure('Storage is not ready. Please try again.');
    final salt = _generateSalt();
    await box.put(_keyEmail, normalizedEmail);
    await box.put(_keySalt, salt);
    await box.put(_keyHash, _hash(password, salt));
    await box.put(_keyLoggedIn, true);
    return AuthResult.success();
  }

  /// Validates [email]/[password] against the stored credential.
  Future<AuthResult> login({required String email, required String password}) async {
    final box = _box;
    if (box == null) return AuthResult.failure('Storage is not ready. Please try again.');
    final storedEmail = box.get(_keyEmail) as String?;
    final storedSalt = box.get(_keySalt) as String?;
    final storedHash = box.get(_keyHash) as String?;
    if (storedEmail == null || storedSalt == null || storedHash == null) {
      return AuthResult.failure('No account found on this device. Please sign up first.');
    }
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail != storedEmail || _hash(password, storedSalt) != storedHash) {
      return AuthResult.failure('Incorrect email or password.');
    }
    await box.put(_keyLoggedIn, true);
    return AuthResult.success();
  }

  /// Clears the "logged in" flag. The stored credential is kept so the user
  /// can log back in without signing up again.
  Future<void> logout() async {
    await _box?.put(_keyLoggedIn, false);
  }
}

class AuthResult {
  final bool ok;
  final String? message;
  const AuthResult._(this.ok, this.message);
  factory AuthResult.success() => const AuthResult._(true, null);
  factory AuthResult.failure(String message) => AuthResult._(false, message);
}
