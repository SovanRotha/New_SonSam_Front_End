import 'package:flutter/material.dart';
import 'package:sansom/models/account/account_model.dart';
import 'package:sansom/service/account/account_servise.dart';

class AccountProvider extends ChangeNotifier {
  final AccountServise accountService = AccountServise();
  List<AccountModel> accountModel = [];
  bool isLoading = false;

  String? errorMessage;

  // Get account types

  Future<void> getAccounts() async {
    isLoading = true;

    errorMessage = null;

    notifyListeners();

    try {
      final response = await accountService.getAccount();

      final accountResponse = response['accounts'] ?? response['account'];
      final List<dynamic> accountData = accountResponse is List
          ? accountResponse
          : accountResponse is Map<String, dynamic>
          ? [accountResponse]
          : [];

      accountModel = accountData
          .whereType<Map<String, dynamic>>()
          .map(AccountModel.fromJson)
          .toList();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;

    notifyListeners();
  }

  // Get one account type

  Future<AccountModel?> getAccount(int id) async {
    isLoading = true;

    errorMessage = null;

    notifyListeners();

    try {
      final response = await accountService.getAccount();

      if (response['account'] != null) {
        final accountData = response['account'];

        if (accountData is Map<String, dynamic>) {
          final account = AccountModel.fromJson(accountData);
          return account.id == id ? account : null;
        }

        if (accountData is List) {
          for (final json in accountData) {
            final account = AccountModel.fromJson(json);
            if (account.id == id) {
              return account;
            }
          }
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

  // Create account type

  Future<bool> createAccount(Map<String, dynamic> accountData) async {
    isLoading = true;

    errorMessage = null;

    notifyListeners();

    try {
      final response = await accountService.createAccount(accountData);

      // Depending on your create API response

      if (response['account'] != null) {
        accountModel.add(AccountModel.fromJson(response['account']));
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

  Future<bool> updateAccount(int id, Map<String, dynamic> accountData) async {
    isLoading = true;

    errorMessage = null;

    notifyListeners();

    try {
      final response = await accountService.updateAccount(id, accountData);

      if (response['account'] != null) {
        final updatedAccountType = AccountModel.fromJson(response['account']);

        final index = accountModel.indexWhere(
          (accountType) => accountType.id == id,
        );

        if (index != -1) {
          accountModel[index] = updatedAccountType;
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

  Future<bool> deleteAccount(int id) async {
    isLoading = true;

    errorMessage = null;

    notifyListeners();

    try {
      await accountService.deleteAccount(id);

      accountModel.removeWhere((account) => account.id == id);

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
