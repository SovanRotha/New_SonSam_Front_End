import 'package:flutter/material.dart';
import 'package:sansom/models/transaction/transaction_model.dart';
import 'package:sansom/service/transaction/transaction_service.dart';

class MonthlyTransactionSummary {
  final int year;
  final int month;
  final double income;
  final double expense;

  const MonthlyTransactionSummary({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
  });
}

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double _income = 0;
  double _expense = 0;
  double _net = 0;
  bool _isSummaryLoading = false;
  String? _summaryErrorMessage;
  List<MonthlyTransactionSummary> _monthlySummary = [];

  double get income => _income;
  double get expense => _expense;
  double get net => _net;
  bool get isSummaryLoading => _isSummaryLoading;
  String? get summaryErrorMessage => _summaryErrorMessage;
  List<MonthlyTransactionSummary> get monthlySummary => _monthlySummary;

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

  Future<bool> summaryTransactions(String token) async {
    _isSummaryLoading = true;
    _summaryErrorMessage = null;
    notifyListeners();

    try {
      final responseData = await _service.summaryTransaction(token);

      final summary = responseData['summary'];
      final values = summary is Map<String, dynamic> ? summary : responseData;
      final responseTransactions = responseData['transactions'];

      if (responseTransactions is List) {
        _setSummaryFromTransactions(responseTransactions);
      } else {
        _income = _asDouble(values['income']);
        _expense = _asDouble(values['expense']);
        _net = values.containsKey('net')
            ? _asDouble(values['net'])
            : _income - _expense;
      }
      return true;
    } catch (e) {
      _summaryErrorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSummaryLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadMonthlySummary(String token) async {
    _isSummaryLoading = true;
    _summaryErrorMessage = null;
    notifyListeners();

    try {
      final data = await _service.monthlySummary(token);
      _monthlySummary = data.map((item) {
        return MonthlyTransactionSummary(
          year: int.tryParse(item['year'].toString()) ?? 0,
          month: int.tryParse(item['month'].toString()) ?? 0,
          income: _asDouble(item['income']),
          expense: _asDouble(item['expense']),
        );
      }).toList();
      return true;
    } catch (e) {
      _summaryErrorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSummaryLoading = false;
      notifyListeners();
    }
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  void _setSummaryFromTransactions(List<dynamic> values) {
    _income = 0;
    _expense = 0;

    for (final value in values) {
      if (value is! Map<String, dynamic>) continue;

      final amount = _asDouble(value['amount']).abs();
      final type = value['type']?.toString().toLowerCase();
      if (type == 'income') {
        _income += amount;
      } else {
        _expense += amount;
      }
    }

    _net = _income - _expense;
  }
}

