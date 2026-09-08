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

      final rawGoalData =
          response['savings_goal'] ??
          response['goals'] ??
          response['data'] ??
          <dynamic>[];

      final List<dynamic> goalData = rawGoalData is List
          ? rawGoalData
          : rawGoalData is Map
          ? [rawGoalData]
          : [];

      goals = goalData
          .whereType<Map>()
          .map((goal) => GoalModel.fromJson(Map<String, dynamic>.from(goal)))
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

      final rawGoal =
          response['savings_goal'] ?? response['goal'] ?? response['data'];

      if (rawGoal is Map<String, dynamic>) {
        return GoalModel.fromJson(rawGoal);
      }

      if (rawGoal is Map) {
        return GoalModel.fromJson(Map<String, dynamic>.from(rawGoal));
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

      final rawGoal =
          response['savings_goal'] ?? response['goal'] ?? response['data'];

      if (rawGoal is Map) {
        final newGoal = GoalModel.fromJson(Map<String, dynamic>.from(rawGoal));

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

      final rawGoal =
          response['savings_goal'] ?? response['goal'] ?? response['data'];

      if (rawGoal is Map) {
        final updatedGoal = GoalModel.fromJson(
          Map<String, dynamic>.from(rawGoal),
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

      final rawGoal =
          response['savings_goal'] ?? response['goal'] ?? response['data'];

      GoalModel? updatedGoal;

      if (rawGoal is Map<String, dynamic>) {
        updatedGoal = GoalModel.fromJson(rawGoal);
      } else if (rawGoal is Map) {
        updatedGoal = GoalModel.fromJson(Map<String, dynamic>.from(rawGoal));
      } else {
        // If API only returns a success message,
        // get the latest goal from the backend.
        updatedGoal = await getGoal(id);
      }

      final index = goals.indexWhere((goal) => goal.id == id);

      if (index != -1 && updatedGoal != null) {
        goals[index] = updatedGoal;
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

  // Refresh one goal from backend

  Future<void> refreshGoal(int id) async {
    try {
      final updatedGoal = await getGoal(id);

      if (updatedGoal == null) {
        return;
      }

      final index = goals.indexWhere((goal) => goal.id == id);

      if (index != -1) {
        goals[index] = updatedGoal;
      }

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
