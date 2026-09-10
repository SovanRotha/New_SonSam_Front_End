import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';


class AccountServise {

  Future<Map<String, String>> getHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getAccount() async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/accounts'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.body.trim().isEmpty) {
        return {};
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to load account: ${response.body}',
    );
  }

  Future<Map<String, dynamic>> createAccount(
    Map<String, dynamic> accountData,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/accounts'),
      headers: await getHeaders(),
      body: jsonEncode(accountData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to create account: ${response.body}',
    );
  }


  Future<Map<String, dynamic>> updateAccount(
    int id,
    Map<String, dynamic> accountData,
  ) async {
    var response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/accounts/$id'),
      headers: await getHeaders(),
      body: jsonEncode(accountData),
    );

    if (response.statusCode == 405) {
      response = await http.patch(
        Uri.parse('${ApiUrl.baseUrl}/accounts/$id'),
        headers: await getHeaders(),
        body: jsonEncode(accountData),
      );
    }

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      if (response.body.trim().isEmpty) {
        return {};
      }

      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : {};
    }

    throw Exception(
      'Failed to update account: ${response.body}',
    );
  }


  Future<void> deleteAccount(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/accounts/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to delete account: ${response.body}',
      );
    }
  }

  Future<void> deactivateAccount(int id) async {
    final response = await http.patch(
      Uri.parse('${ApiUrl.baseUrl}/accounts/$id/deactivate'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to deactivate account: ${response.body}',
      );
    }
  }
}