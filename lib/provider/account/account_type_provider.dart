import 'package:flutter/material.dart';

import 'package:sansom/models/account/account_type_model.dart';
import 'package:sansom/service/account/account_type_service.dart';

class AccountTypeProvider extends ChangeNotifier {
  final AccountTypeService accountTypeService = AccountTypeService();

  List<AccountTypeModel> accountTypes = [];

  bool isLoading = false;

  String? errorMessage;

  // =========================================================
  // GET ALL ACCOUNT TYPES
  // =========================================================

  Future<void> getAccountTypes() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await accountTypeService.getAccountTypes();

      final dynamic accountTypeResponse;
      if (response is List) {
        accountTypeResponse = response;
      } else if (response is Map<String, dynamic>) {
        accountTypeResponse =
            response['accountTypes'] ??
            response['account_types'] ??
            response['accountType'] ??
            response['data'] ??
            [];
      } else {
        accountTypeResponse = [];
      }

      if (accountTypeResponse is List) {
        accountTypes = accountTypeResponse
            .whereType<Map<String, dynamic>>()
            .map((json) => AccountTypeModel.fromJson(json))
            .toList();
      } else if (accountTypeResponse is Map<String, dynamic>) {
        accountTypes = [AccountTypeModel.fromJson(accountTypeResponse)];
      } else {
        accountTypes = [];
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // GET ONE ACCOUNT TYPE
  // =========================================================

  Future<AccountTypeModel?> getAccountType(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await accountTypeService.getAccountType(id);

      final dynamic accountTypeResponse = response is List
          ? response
          : response is Map<String, dynamic>
          ? response['accountType'] ??
                response['accountTypes'] ??
                response['account_type'] ??
                response['data']
          : null;

      // API returns:
      //
      // "accountTypes": [
      //   {
      //     "id": 1,
      //     "name": "ABA"
      //   }
      // ]

      if (accountTypeResponse is List) {
        for (final json in accountTypeResponse) {
          if (json is Map<String, dynamic>) {
            final accountType = AccountTypeModel.fromJson(json);

            if (accountType.id == id) {
              return accountType;
            }
          }
        }
      }

      // API returns:
      //
      // "accountType": {
      //   "id": 1,
      //   "name": "ABA"
      // }

      if (accountTypeResponse is Map<String, dynamic>) {
        final accountType = AccountTypeModel.fromJson(accountTypeResponse);

        if (accountType.id == id) {
          return accountType;
        }
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

  // =========================================================
  // CREATE ACCOUNT TYPE
  // =========================================================

  Future<bool> createAccountType(Map<String, dynamic> accountTypeData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await accountTypeService.createAccountType(
        accountTypeData,
      );

      final accountTypeResponse =
          response['accountType'] ??
          response['accountTypes'] ??
          response['account_type'] ??
          response['data'];

      // If API returns a single account type
      if (accountTypeResponse is Map<String, dynamic>) {
        final accountType = AccountTypeModel.fromJson(accountTypeResponse);

        accountTypes.add(accountType);
      }
      // If API returns a list
      else if (accountTypeResponse is List) {
        for (final json in accountTypeResponse) {
          if (json is Map<String, dynamic>) {
            accountTypes.add(AccountTypeModel.fromJson(json));
          }
        }
      }

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // UPDATE ACCOUNT TYPE
  // =========================================================

  Future<bool> updateAccountType(
    int id,
    Map<String, dynamic> accountTypeData,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await accountTypeService.updateAccountType(
        id,
        accountTypeData,
      );

      final accountTypeResponse =
          response['accountType'] ??
          response['accountTypes'] ??
          response['account_type'] ??
          response['data'];

      AccountTypeModel? updatedAccountType;

      // Single object
      if (accountTypeResponse is Map<String, dynamic>) {
        updatedAccountType = AccountTypeModel.fromJson(accountTypeResponse);
      }
      // List
      else if (accountTypeResponse is List) {
        for (final json in accountTypeResponse) {
          if (json is Map<String, dynamic>) {
            final accountType = AccountTypeModel.fromJson(json);

            if (accountType.id == id) {
              updatedAccountType = accountType;
              break;
            }
          }
        }
      }

      // Update local list
      if (updatedAccountType != null) {
        final index = accountTypes.indexWhere(
          (accountType) => accountType.id == id,
        );

        if (index != -1) {
          accountTypes[index] = updatedAccountType;
        }
      }

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // DELETE ACCOUNT TYPE
  // =========================================================

  Future<bool> deleteAccountType(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await accountTypeService.deleteAccountType(id);

      // Remove from local list
      accountTypes.removeWhere((accountType) => accountType.id == id);

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // CLEAR ERROR
  // =========================================================

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
