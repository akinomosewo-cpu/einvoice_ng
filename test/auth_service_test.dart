import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:einvoice_ng/data/auth_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('einvoice_auth_test');
    // Point Hive at a real temp directory directly, since
    // hive_flutter's initFlutter() needs the path_provider platform
    // channel, which isn't available under flutter_test.
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('signup stores a hashed credential and logs the user in', () async {
    final auth = AuthService();
    await auth.init();

    expect(auth.hasAccount, isFalse);
    expect(auth.isLoggedIn, isFalse);

    final result = await auth.signUp(email: 'Owner@Business.com', password: 'supersecret');

    expect(result.ok, isTrue);
    expect(auth.hasAccount, isTrue);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.currentEmail, 'owner@business.com');

    // The raw password must never be persisted verbatim.
    final box = await Hive.openBox('auth_box');
    final values = box.values.whereType<String>();
    expect(values.any((v) => v == 'supersecret'), isFalse);
  });

  test('login succeeds with the correct email and password', () async {
    final auth = AuthService();
    await auth.init();
    await auth.signUp(email: 'owner@business.com', password: 'correcthorse');
    await auth.logout();

    expect(auth.isLoggedIn, isFalse);

    final result = await auth.login(email: 'owner@business.com', password: 'correcthorse');

    expect(result.ok, isTrue);
    expect(auth.isLoggedIn, isTrue);
  });

  test('login is rejected for a wrong password', () async {
    final auth = AuthService();
    await auth.init();
    await auth.signUp(email: 'owner@business.com', password: 'correcthorse');
    await auth.logout();

    final result = await auth.login(email: 'owner@business.com', password: 'wrongpassword');

    expect(result.ok, isFalse);
    expect(auth.isLoggedIn, isFalse);
  });

  test('logout clears the session but keeps the stored account', () async {
    final auth = AuthService();
    await auth.init();
    await auth.signUp(email: 'owner@business.com', password: 'correcthorse');
    expect(auth.isLoggedIn, isTrue);

    await auth.logout();

    expect(auth.isLoggedIn, isFalse);
    expect(auth.hasAccount, isTrue);

    // The same credential still works after logging back in.
    final result = await auth.login(email: 'owner@business.com', password: 'correcthorse');
    expect(result.ok, isTrue);
  });
}
