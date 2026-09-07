import 'package:flutter/material.dart';
import 'package:sansom/models/contribution/contribution_model.dart';
import 'package:sansom/service/contribution/contribution_service.dart';

class ContributionProvider extends ChangeNotifier {
  final ContributionService contributionService = ContributionService();

  List<ContributionModel> contributions = [];

  bool isLoading = false;
  String? errorMessage;

  // =========================
  // GET ALL CONTRIBUTIONS
  // =========================
  Future<void> getContributions() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await contributionService.getContributions();

      final List<dynamic> data = response['contributions'] ?? [];

      contributions = data
          .map((json) => ContributionModel.fromJson(json))
          .toList();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // =========================
  // GET ONE CONTRIBUTION
  // =========================
  Future<ContributionModel?> getContribution(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await contributionService.getContribution(id);

      final data = response['contribution'];

      if (data != null) {
        final contribution = ContributionModel.fromJson(data);

        isLoading = false;
        notifyListeners();

        return contribution;
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();

    return null;
  }

  // =========================
  // CREATE CONTRIBUTION
  // =========================
  Future<bool> createContribution(Map<String, dynamic> contributionData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await contributionService.createContribution(
        contributionData,
      );

      final data = response['contribution'];

      if (data != null) {
        final contribution = ContributionModel.fromJson(data);

        contributions.insert(0, contribution);
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

  // =========================
  // UPDATE CONTRIBUTION
  // =========================
  Future<bool> updateContribution(
    int id,
    Map<String, dynamic> contributionData,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await contributionService.updateContribution(
        id,
        contributionData,
      );

      final data = response['contribution'];

      if (data != null) {
        final updatedContribution = ContributionModel.fromJson(data);

        final index = contributions.indexWhere((item) => item.id == id);

        if (index != -1) {
          contributions[index] = updatedContribution;
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

  // =========================
  // DELETE CONTRIBUTION
  // =========================
  Future<bool> deleteContribution(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await contributionService.deleteContribution(id);

      contributions.removeWhere((item) => item.id == id);

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
