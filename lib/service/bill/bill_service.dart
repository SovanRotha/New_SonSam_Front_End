
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';

class BillService {
  Future<Map<String, String>> getHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET /bills
  Future<Map<String, dynamic>> getBills() async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/bills'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load bills: ${response.body}',
    );
  }

  // GET /bills/{id}
  Future<Map<String, dynamic>> getBill(int id) async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/bills/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load bill: ${response.body}',
    );
  }

  // POST /bills
  Future<Map<String, dynamic>> createBill(
    Map<String, dynamic> billData,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/bills'),
      headers: await getHeaders(),
      body: jsonEncode(billData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to create bill: ${response.body}',
    );
  }

  // PUT /bills/{id}
  Future<Map<String, dynamic>> updateBill(
    int id,
    Map<String, dynamic> billData,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/bills/$id'),
      headers: await getHeaders(),
      body: jsonEncode(billData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to update bill: ${response.body}',
    );
  }

  // DELETE /bills/{id}
  Future<void> deleteBill(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/bills/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to delete bill: ${response.body}',
      );
    }
  }
}
