import 'package:flutter/material.dart';
import 'package:sansom/models/goal/goal_model.dart';
import 'package:sansom/service/goal/goal_service.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService goalService = GoalService();

  List<GoalModel> goals = [];

  bool isLoading = false;
  String? errorMessage;

  // GET /goals
  Future<void> getGoals() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await goalService.getGoals();

      final List<dynamic> goalData = response['savings_goal'] ?? [];

      goals = goalData
          .map((json) => GoalModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // GET /goals/{id}
  Future<GoalModel?> getGoal(int id) async {
    try {
      final response = await goalService.getGoal(id);

      if (response['savings_goal'] != null) {
        return GoalModel.fromJson(response['savings_goal'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return null;
    }
  }

  // POST /goals
  Future<bool> createGoal(Map<String, dynamic> goalData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await goalService.createGoal(goalData);

      if (response['savings_goal'] != null) {
        final newGoal = GoalModel.fromJson(
          response['savings_goal'] as Map<String, dynamic>,
        );

        goals.insert(0, newGoal);
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

  // PUT /goals/{id}
  Future<bool> updateGoal(int id, Map<String, dynamic> goalData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await goalService.updateGoal(id, goalData);

      if (response['savings_goal'] != null) {
        final updatedGoal = GoalModel.fromJson(
          response['savings_goal'] as Map<String, dynamic>,
        );

        final index = goals.indexWhere((goal) => goal.id == id);

        if (index != -1) {
          goals[index] = updatedGoal;
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

  // DELETE /goals/{id}
  Future<bool> deleteGoal(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await goalService.deleteGoal(id);

      goals.removeWhere((goal) => goal.id == id);

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

  // POST /goals/{id}/add-money
  Future<bool> addMoney(int id, double amount) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await goalService.addMoney(id, amount);

      if (response['savings_goal'] != null) {
        final updatedGoal = GoalModel.fromJson(
          response['savings_goal'] as Map<String, dynamic>,
        );

        final index = goals.indexWhere((goal) => goal.id == id);

        if (index != -1) {
          goals[index] = updatedGoal;
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
}
