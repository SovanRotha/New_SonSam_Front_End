
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';

class BudgetCategoryService {
  // Add your methods and properties here

  Future<Map<String, String>> getHeaders() async {
    // Implement your logic to get headers, e.g., authentication tokens
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token', // Replace with actual token retrieval
      // Add other headers as needed
    };
  }

  Future<Map<String, dynamic>> getBudgetCategories(int budgetId) async {
  final response = await http.get(
    Uri.parse('${ApiUrl.baseUrl}/budgetCategories/$budgetId'),
    headers: await getHeaders(),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'Failed to load budget categories: ${response.body}',
  );
}

  Future<Map<String, dynamic>> createBudgetCategory(
    Map<String, dynamic> budgetCategoryData,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/budgetCategories'),
      headers: await getHeaders(),
      body: jsonEncode(budgetCategoryData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to create budget category: ${response.body}',
    );
  }

  Future<Map<String, dynamic>> updateBudgetCategory(
    int id,
    Map<String, dynamic> budgetCategoryData,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/budgetCategories/$id'),
      headers: await getHeaders(),
      body: jsonEncode(budgetCategoryData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to update budget category: ${response.body}',
    );
  }

  Future<void> deleteBudgetCategory(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/budgetCategories/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete budget category: ${response.body}',
      );
    }
  }
  
}