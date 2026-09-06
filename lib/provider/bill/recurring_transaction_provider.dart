import 'package:flutter/material.dart';
import 'package:sansom/models/bill/recurring_transaction.dart';
import 'package:sansom/service/bill/recurring_transaction_service.dart';

class RecurringTransactionProvider extends ChangeNotifier {
  final RecurringTransactionService recurringTransactionService =
      RecurringTransactionService();
  List<RecurringTransaction> recurringTransactions = [];
  bool isLoading = false;

  String? errorMessage;

  Future<void> getRecurring() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await recurringTransactionService
          .getRecurringTransactions();
      final recurringData = response['recurringTransaction'];

      if (recurringData is List) {
        recurringTransactions = recurringData
            .map((json) => RecurringTransaction.fromJson(json))
            .toList();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<RecurringTransaction?> getRecurringTransaction(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await recurringTransactionService
          .getRecurringTransaction(id);
      final recurringData = response['recurringTransaction'];

      if (recurringData is Map<String, dynamic>) {
        return RecurringTransaction.fromJson(recurringData);
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

  Future<bool> createRecurringTransaction(
    Map<String, dynamic> recurringData,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await recurringTransactionService
          .createRecurringTransaction(recurringData);
      final createdData = response['recurringTransaction'];

      if (createdData is Map<String, dynamic>) {
        recurringTransactions.add(RecurringTransaction.fromJson(createdData));
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

  Future<bool> updateRecurringTransaction(
    int id,
    Map<String, dynamic> recurringData,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await recurringTransactionService
          .updateRecurringTransaction(id, recurringData);
      final updatedData = response['recurringTransaction'];

      if (updatedData is Map<String, dynamic>) {
        final updatedTransaction = RecurringTransaction.fromJson(updatedData);
        final index = recurringTransactions.indexWhere(
          (transaction) => transaction.id == id,
        );

        if (index != -1) {
          recurringTransactions[index] = updatedTransaction;
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

  Future<bool> deleteRecurringTransaction(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await recurringTransactionService.deleteRecurringTransaction(id);
      recurringTransactions.removeWhere((transaction) => transaction.id == id);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
