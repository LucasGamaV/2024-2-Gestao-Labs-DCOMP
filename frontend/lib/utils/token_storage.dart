library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'bearer_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'bearer_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'bearer_token');
  }
}