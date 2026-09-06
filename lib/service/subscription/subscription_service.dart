import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';

class SubscriptionService {
  Future<Map<String, String>> getHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ========================================
  // GET ALL SUBSCRIPTIONS
  // GET /subscriptions
  // ========================================

  Future<Map<String, dynamic>> getSubscriptions() async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/subscriptions'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load subscriptions: ${response.body}');
  }

  // ========================================
  // GET ONE SUBSCRIPTION
  // GET /subscriptions/{id}
  // ========================================

  Future<Map<String, dynamic>> getSubscription(int id) async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/subscriptions/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load subscription: ${response.body}');
  }

  // ========================================
  // CREATE SUBSCRIPTION
  // POST /subscriptions
  // ========================================

  Future<Map<String, dynamic>> createSubscription(
    Map<String, dynamic> subscriptionData,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/subscriptions'),
      headers: await getHeaders(),
      body: jsonEncode(subscriptionData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to create subscription: ${response.body}');
  }

  // ========================================
  // UPDATE SUBSCRIPTION
  // PUT /subscriptions/{id}
  // ========================================

  Future<Map<String, dynamic>> updateSubscription(
    int id,
    Map<String, dynamic> subscriptionData,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/subscriptions/$id'),
      headers: await getHeaders(),
      body: jsonEncode(subscriptionData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to update subscription: ${response.body}');
  }

  // ========================================
  // DELETE SUBSCRIPTION
  // DELETE /subscriptions/{id}
  // ========================================

  Future<void> deleteSubscription(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/subscriptions/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete subscription: ${response.body}');
    }
  }
}
