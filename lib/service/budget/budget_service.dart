import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';

class BudgetService {

  Future<Map<String, String>> getHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getBudget() async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/budgets'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load budget: ${response.body}',
    );
  }

  Future<Map<String, dynamic>> createBudget(
    Map<String, dynamic> budgetData,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/budgets'),
      headers: await getHeaders(),
      body: jsonEncode(budgetData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to create budget: ${response.body}',
    );
  }

  Future<Map<String, dynamic>> updateBudget(
    int id,
    Map<String, dynamic> budgetData,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/budgets/$id'),
      headers: await getHeaders(),
      body: jsonEncode(budgetData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to update budget: ${response.body}',
    );
  }

  Future<void> deleteBudget(int id) async {
  final response = await http.delete(
    Uri.parse('${ApiUrl.baseUrl}/budgets/$id'),
    headers: await getHeaders(),
  );

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception(
      'Failed to delete budget: ${response.body}',
    );
  }
}
}