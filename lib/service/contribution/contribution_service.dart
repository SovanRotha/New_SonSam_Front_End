
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';

class ContributionService {
  Future<Map<String, String>> getHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET /contributions
  Future<Map<String, dynamic>> getContributions() async {
    final response = await http.get(
      Uri.parse(
        '${ApiUrl.baseUrl}/contributions',
      ),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load contributions: ${response.body}',
    );
  }

  // GET /contributions/{id}
  Future<Map<String, dynamic>> getContribution(
    int id,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiUrl.baseUrl}/contributions/$id',
      ),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load contribution: ${response.body}',
    );
  }

  // POST /contributions
  Future<Map<String, dynamic>> createContribution(
    Map<String, dynamic> contributionData,
  ) async {
    final response = await http.post(
      Uri.parse(
        '${ApiUrl.baseUrl}/contributions',
      ),
      headers: await getHeaders(),
      body: jsonEncode(contributionData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to create contribution: ${response.body}',
    );
  }

  // PUT /contributions/{id}
  Future<Map<String, dynamic>> updateContribution(
    int id,
    Map<String, dynamic> contributionData,
  ) async {
    final response = await http.put(
      Uri.parse(
        '${ApiUrl.baseUrl}/contributions/$id',
      ),
      headers: await getHeaders(),
      body: jsonEncode(contributionData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to update contribution: ${response.body}',
    );
  }

  // DELETE /contributions/{id}
  Future<void> deleteContribution(int id) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiUrl.baseUrl}/contributions/$id',
      ),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to delete contribution: ${response.body}',
      );
    }
  }
}
