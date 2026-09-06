import 'package:flutter/material.dart';
import 'package:sansom/models/subscription/subscription_model.dart';
import 'package:sansom/service/subscription/subscription_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService subscriptionService = SubscriptionService();

  List<SubscriptionModel> subscriptions = [];

  bool isLoading = false;
  String? errorMessage;

  // ========================================
  // GET ALL SUBSCRIPTIONS
  // ========================================

  Future<void> getSubscriptions() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await subscriptionService.getSubscriptions();

      final List<dynamic> subscriptionData = response['subscriptions'] ?? [];

      subscriptions = subscriptionData.map(
            (json) => SubscriptionModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // ========================================
  // GET ONE SUBSCRIPTION
  // ========================================

  Future<SubscriptionModel?> getSubscription(int id) async {
    try {
      final response = await subscriptionService.getSubscription(id);

      if (response['subscription'] != null) {
        return SubscriptionModel.fromJson(response['subscription']);
      }

      return null;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return null;
    }
  }

  // ========================================
  // CREATE SUBSCRIPTION
  // ========================================

  Future<bool> createSubscription(Map<String, dynamic> subscriptionData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await subscriptionService.createSubscription(
        subscriptionData,
      );

      if (response['subscription'] != null) {
        final newSubscription = SubscriptionModel.fromJson(
          response['subscription'],
        );

        subscriptions.insert(0, newSubscription);
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

  // ========================================
  // UPDATE SUBSCRIPTION
  // ========================================

  Future<bool> updateSubscription(
    int id,
    Map<String, dynamic> subscriptionData,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await subscriptionService.updateSubscription(
        id,
        subscriptionData,
      );

      if (response['subscription'] != null) {
        final updatedSubscription = SubscriptionModel.fromJson(
          response['subscription'],
        );

        final index = subscriptions.indexWhere(
          (subscription) => subscription.id == id,
        );

        if (index != -1) {
          subscriptions[index] = updatedSubscription;
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

  // ========================================
  // DELETE SUBSCRIPTION
  // ========================================

  Future<bool> deleteSubscription(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await subscriptionService.deleteSubscription(id);

      subscriptions.removeWhere((subscription) => subscription.id == id);

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
