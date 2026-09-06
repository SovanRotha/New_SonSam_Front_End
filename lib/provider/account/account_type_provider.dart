import 'package:flutter/material.dart';

import 'package:sansom/models/account/account_type_model.dart';

import 'package:sansom/service/account/account_type_service.dart';

class AccountTypeProvider extends ChangeNotifier {

  final AccountTypeService accountTypeService =
      AccountTypeService();

  List<AccountTypeModel> accountTypes = [];

  bool isLoading = false;

  String? errorMessage;

  // Get account types

  Future<void> getAccountTypes() async {

    isLoading = true;

    errorMessage = null;

    notifyListeners();

    try {

      final response =
          await accountTypeService.getAccountTypes();

      final List<dynamic> accountTypeData =
          response['accountType'];

      accountTypes = accountTypeData
          .map((json) => AccountTypeModel.fromJson(json))
          .toList();

    } catch (e) {

      errorMessage = e.toString();

    }

    isLoading = false;

    notifyListeners();
  }

  // Get one account type

  Future<AccountTypeModel?> getAccountType(int id) async {

    isLoading = true;

    errorMessage = null;

    notifyListeners();

    try {

      final response =
          await accountTypeService.getAccountType(id);

      if (response['accountType'] != null) {

        return AccountTypeModel.fromJson(
          response['accountType'],
        );

      }

      return null;

    } catch (e) {

      errorMessage = e.toString();

      return null;

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }

  // Create account type

  Future<bool> createAccountType(
    Map<String, dynamic> accountTypeData,
  ) async {

    isLoading = true;

    errorMessage = null;

    notifyListeners();

    try {

      final response =
          await accountTypeService.createAccountType(
        accountTypeData,
      );

      // Depending on your create API response

      if (response['accountType'] != null) {

        accountTypes.add(
          AccountTypeModel.fromJson(
            response['accountType'],
          ),
        );

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

  // Update account type

  Future<bool> updateAccountType(
    int id,
    Map<String, dynamic> accountTypeData,
  ) async {

    isLoading = true;

    errorMessage = null;

    notifyListeners();

    try {

      final response =
          await accountTypeService.updateAccountType(
        id,
        accountTypeData,
      );

      if (response['accountType'] != null) {

        final updatedAccountType =
            AccountTypeModel.fromJson(
          response['accountType'],
        );

        final index = accountTypes.indexWhere(
          (accountType) => accountType.id == id,
        );

        if (index != -1) {

          accountTypes[index] = updatedAccountType;

        }

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

  // Delete account type

  Future<bool> deleteAccountType(int id) async {

    isLoading = true;

    errorMessage = null;

    notifyListeners();

    try {

      await accountTypeService.deleteAccountType(id);

      accountTypes.removeWhere(
        (accountType) => accountType.id == id,
      );

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
}

