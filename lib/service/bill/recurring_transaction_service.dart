import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';

class RecurringTransactionService {
  // Headers
  Future<Map<String, String>> getHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET: /recurrings
  Future<Map<String, dynamic>> getRecurringTransactions() async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/recurrings'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load recurring transactions: ${response.body}',
    );
  }

  // GET: /recurrings/{id}
  Future<Map<String, dynamic>> getRecurringTransaction(int id) async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/recurrings/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load recurring transaction: ${response.body}',
    );
  }

  // POST: /recurrings
  Future<Map<String, dynamic>> createRecurringTransaction(
    Map<String, dynamic> recurringData,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/recurrings'),
      headers: await getHeaders(),
      body: jsonEncode(recurringData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to create recurring transaction: ${response.body}',
    );
  }

  // PUT: /recurrings/{id}
  Future<Map<String, dynamic>> updateRecurringTransaction(
    int id,
    Map<String, dynamic> recurringData,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/recurrings/$id'),
      headers: await getHeaders(),
      body: jsonEncode(recurringData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to update recurring transaction: ${response.body}',
    );
  }

  // DELETE: /recurrings/{id}
  Future<void> deleteRecurringTransaction(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/recurrings/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete recurring transaction: ${response.body}',
      );
    }
  }
}