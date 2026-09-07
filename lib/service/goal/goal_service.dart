import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';

class GoalService {
  Future<Map<String, String>> getHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET /goals
  Future<Map<String, dynamic>> getGoals() async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/goals'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load goals: ${response.body}');
  }

  // GET /goals/{id}
  Future<Map<String, dynamic>> getGoal(int id) async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/goals/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load goal: ${response.body}');
  }

  // POST /goals
  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> goalData) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/goals'),
      headers: await getHeaders(),
      body: jsonEncode(goalData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to create goal: ${response.body}');
  }

  // PUT /goals/{id}
  Future<Map<String, dynamic>> updateGoal(
    int id,
    Map<String, dynamic> goalData,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/goals/$id'),
      headers: await getHeaders(),
      body: jsonEncode(goalData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to update goal: ${response.body}');
  }

  // DELETE /goals/{id}
  Future<void> deleteGoal(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/goals/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete goal: ${response.body}');
    }
  }

  // POST /goals/{id}/add-money
  Future<Map<String, dynamic>> addMoney(int id, double amount) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/goals/$id/add-money'),
      headers: await getHeaders(),
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to add money to goal: ${response.body}');
  }
}
