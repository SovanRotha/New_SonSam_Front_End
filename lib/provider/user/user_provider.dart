
import 'package:flutter/material.dart';
import 'package:sansom/models/auth/auth_model.dart';
import 'package:sansom/service/auth/auth_service.dart';
import 'package:sansom/service/user/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService userService = UserService();
  final AuthService authService = AuthService();

  User? user;

  bool isLoading = false;
  String? errorMessage;

  // Get currently logged-in user
  Future<void> getUser() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await userService.me();

        final userData =
          response['user'] ?? response['users'] ?? response['data'] ?? response;

      if (userData is Map<String, dynamic>) {
        user = User.fromJson(userData);
      } else {
        throw Exception('Invalid user response');
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // Set user manually
  void setUser(User user) {
    this.user = user;
    notifyListeners();
  }

  // Clear user
  void clearUser() {
    user = null;
    notifyListeners();
  }


  Future<bool> updateUser(String id, User updatedUser) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await userService.updateUser(
        id,
        updatedUser.toJson(),
      );

      final userData =
          response['user'] ?? response['users'] ?? response['data'] ?? response;

      if (userData is Map<String, dynamic>) {
        user = User.fromJson(userData);
      } else {
        throw Exception('Invalid user response');
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await authService.logout();
      clearUser();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
