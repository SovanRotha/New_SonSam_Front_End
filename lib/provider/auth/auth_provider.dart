import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:sansom/models/auth/auth_model.dart';
import 'package:sansom/service/auth/auth_service.dart';
import 'package:sansom/service/token/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? user;
  

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final request = Login(email: email, password: password);
      final response = await authService.login(request);

      user = response['user'];
      TokenStorage.saveToken(response['token']);
      
      log('${response['token']}');
      
      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = '$e';
      notifyListeners();

      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String phone,
    String currency,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final request = User(
        name: name,
        email: email,
        password: password,
        phone: phone,
        currency: currency,
      );
      final response = await authService.register(request);

      user = response['user'];
      // token = response['token'];

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = '$e';
      notifyListeners();

      return false;
    }
  }
}
