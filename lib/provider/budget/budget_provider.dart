import 'package:flutter/material.dart';
import 'package:sansom/models/budget/budget_model.dart';
import 'package:sansom/service/budget/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService budgetService = BudgetService();

  List<Budget> budgets = [];

  bool isLoading = false;
  String? errorMessage;

  // Get budgets
  Future<void> getBudget() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await budgetService.getBudget();

      final List<dynamic> budgetData = response['budgets'];

      budgets = budgetData
          .map((json) => Budget.fromJson(json))
          .toList();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // Create budget
  Future<bool> createBudget(
    Map<String, dynamic> budgetData,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await budgetService.createBudget(budgetData);

      // Depending on your create API response
      if (response['budget'] != null) {
        budgets.add(
          Budget.fromJson(response['budget']),
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

  // Delete budget
  Future<bool> deleteBudget(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await budgetService.deleteBudget(id);

      budgets.removeWhere((budget) => budget.id == id);

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