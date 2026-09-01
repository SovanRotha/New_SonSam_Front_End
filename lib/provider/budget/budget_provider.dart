
import 'package:flutter/material.dart';
import 'package:sansom/models/budget/budget_model.dart';
import 'package:sansom/service/budget/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService budgetService = BudgetService();

  Budget? budget;

  bool isLoading = false;
  String? errorMessage;

  // Get budget
  Future<void> getBudget() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await budgetService.getBudget();

      budget = Budget.fromJson(response);
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
      final response = await budgetService.createBudget(
        budgetData,
      );

      budget = Budget.fromJson(response);

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
  Future<bool> updateBudget(
    int id,
    Map<String, dynamic> budgetData,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await budgetService.updateBudget(
        id,
        budgetData,
      );

      budget = Budget.fromJson(response);

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

      budget = null;

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

