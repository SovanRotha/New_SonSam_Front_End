import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';

class AccountTypeService {

  Future<Map<String, String>> getHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ================= GET ALL ACCOUNT TYPES =================

  Future<Map<String, dynamic>> getAccountTypes() async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/accountTypes'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load account types: ${response.body}',
    );
  }

  // ================= GET ONE ACCOUNT TYPE =================

  Future<Map<String, dynamic>> getAccountType(int id) async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/accountTypes/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load account type: ${response.body}',
    );
  }

  // ================= CREATE ACCOUNT TYPE =================

  Future<Map<String, dynamic>> createAccountType(
    Map<String, dynamic> accountTypeData,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/accountTypes'),
      headers: await getHeaders(),
      body: jsonEncode(accountTypeData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to create account type: ${response.body}',
    );
  }

  // ================= UPDATE ACCOUNT TYPE =================

  Future<Map<String, dynamic>> updateAccountType(
    int id,
    Map<String, dynamic> accountTypeData,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/accountTypes/$id'),
      headers: await getHeaders(),
      body: jsonEncode(accountTypeData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to update account type: ${response.body}',
    );
  }

  // ================= DELETE ACCOUNT TYPE =================

  Future<void> deleteAccountType(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/accountTypes/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to delete account type: ${response.body}',
      );
    }
  }
}