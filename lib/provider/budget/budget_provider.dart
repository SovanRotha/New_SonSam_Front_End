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

      budgets = budgetData.map((json) => Budget.fromJson(json)).toList();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // Create budget
  Future<bool> createBudget(Map<String, dynamic> budgetData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await budgetService.createBudget(budgetData);

      // Depending on your create API response
      if (response['budgets'] != null) {
        budgets.add(Budget.fromJson(response['budgets']));
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

  // Update budget
  Future<bool> updateBudget(int id, Map<String, dynamic> budgetData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await budgetService.updateBudget(id, budgetData);

      final budgetResponse =
          response['budget'] ?? response['budgets'] ?? response['data'];

      if (budgetResponse is Map<String, dynamic>) {
        final updatedBudget = Budget.fromJson(budgetResponse);

        final index = budgets.indexWhere((budget) => budget.id == id);

        if (index != -1) {
          budgets[index] = updatedBudget;
        }
      } else {
        await getBudget();
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
