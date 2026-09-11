import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';

import 'google_sign_in_service.dart';

class GoogleAuthService {
  final GoogleSignInService googleSignInService =
      GoogleSignInService();

  // Android Emulator
  

  Future<Map<String, dynamic>> registerWithGoogle() async {
    try {
      final idToken = await googleSignInService.authenticate();
      if (idToken == null) {
        throw Exception('Google ID token is null.');
      }

      final response = await http.post(
        Uri.parse('${ApiUrl.baseUrl}/register-google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id_token': idToken}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) return data;

      throw Exception(data['message'] ?? 'Google registration failed.');
    } catch (error) {
      throw Exception('Google registration failed: $error');
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final idToken = await googleSignInService.authenticate();
      if (idToken == null) {
        throw Exception('Google ID token is null.');
      }

      final response = await http.post(
        Uri.parse('${ApiUrl.baseUrl}/login-google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id_token': idToken}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;

      throw Exception(data['message'] ?? 'Google login failed.');
    } catch (error) {
      throw Exception('Google login failed: $error');
    }
  }

  Future<void> signOut() async {
    await googleSignInService.signOut();
  }
}