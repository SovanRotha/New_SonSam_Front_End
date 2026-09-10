import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';


class UserService {
  // Add your user service methods here
  Future<Map<String, String>> getHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> me() async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/me'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to load user data');
  }
  
  Future<Map<String, dynamic>> getUser(String id) async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/users/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      if (response.body.trim().isEmpty) {
        return {};
      }

      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : {};
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<Map<String, dynamic>> updateUser(
    String id,
    Map<String, dynamic> userData,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/users/$id'),
      headers: await getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user data');
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/users/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/users'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load users');
    }
  }

  
}