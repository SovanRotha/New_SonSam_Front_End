import 'package:flutter/widgets.dart';
import 'package:sansom/models/budget/budget_category_model.dart';
import 'package:sansom/service/budget/budget_category_service.dart';

class BudgetCategoryProvider extends ChangeNotifier {
  final BudgetCategoryService budgetCategoryService = BudgetCategoryService();

  List<BudgetCategory> budgetCategories = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> getBudgetCategory(int budgetId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await budgetCategoryService.getBudgetCategories(
        budgetId,
      );

      final List<dynamic> budgetCategoryData = response['budget_categories'];

      budgetCategories = budgetCategoryData
          .map((json) => BudgetCategory.fromJson(json))
          .toList();

      print('Number of budget categories: ${budgetCategories.length}');

      for (final budgetCategory in budgetCategories) {
        print('Budget Category ID: ${budgetCategory.id}');
        print('Category ID: ${budgetCategory.categoryId}');
        print('Category Name: ${budgetCategory.category?.name}');
        print('Category Type: ${budgetCategory.category?.type}');
      }
    } catch (e) {
      errorMessage = e.toString();
      print('Error fetching budget categories: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> createBudgetCategory(
    Map<String, dynamic> budgetCategoryData,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await budgetCategoryService.createBudgetCategory(
        budgetCategoryData,
      );

      if (response['budget_categories'] != null) {
        budgetCategories.add(
          BudgetCategory.fromJson(response['budget_categories']),
        );
      }
    } catch (e) {
      // Handle error
      print('Error creating budget category: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateBudgetCategory(
    int id,
    Map<String, dynamic> budgetCategoryData,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await budgetCategoryService.updateBudgetCategory(
        id,
        budgetCategoryData,
      );

      if (response['budget_categories'] != null) {
        final index = budgetCategories.indexWhere(
          (category) => category.id == id,
        );
        if (index != -1) {
          budgetCategories[index] = BudgetCategory.fromJson(
            response['budget_categories'],
          );
        }
      }
    } catch (e) {
      // Handle error
      print('Error updating budget category: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteBudgetCategory(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await budgetCategoryService.deleteBudgetCategory(id);

      budgetCategories.removeWhere((category) => category.id == id);
    } catch (e) {
      // Handle error
      print('Error deleting budget category: $e');
    }
    isLoading = false;
    notifyListeners();
  }
}
