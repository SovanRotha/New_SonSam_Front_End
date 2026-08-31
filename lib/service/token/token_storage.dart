

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage{
  static const storage = FlutterSecureStorage();

  static const String tokenKey = 'sanSom-token';

  static Future<void> saveToken(String token) async{
    await storage.write(key: tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await storage.read(key: tokenKey);
  }

  static Future<void> deleteToken() async {
    await storage.delete(
      key: tokenKey,
    );
  }

}