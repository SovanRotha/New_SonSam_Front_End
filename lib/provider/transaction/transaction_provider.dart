import 'package:flutter/material.dart';
import 'package:sansom/models/transaction/transaction_model.dart';
import 'package:sansom/service/transaction/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch Transactions
  Future<void> loadTransactions(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _service.fetchTransactions(token);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add Transaction
  Future<bool> addTransaction(
    String token,
    TransactionModel transaction,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.createTransaction(token, transaction);
      if (success) {
        await loadTransactions(token);
        return true;
      } else {
        _errorMessage = "Failed to create transaction";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
