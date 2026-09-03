
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/models/category/category_model.dart';
import 'package:sansom/service/token/token_storage.dart';

class CategoryService {
  
  Future<Map<String, String>> getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${await TokenStorage.getToken()}',
    };
  }

  Future<Map<String, dynamic>> getCategory() async {
    final response = await http.get(Uri.parse('${ApiUrl.baseUrl}/categories'), 
    headers: await getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> categoryData) async {
    final response = await http.post(Uri.parse('${ApiUrl.baseUrl}/categories'), 
    headers: await getHeaders(),
    body: jsonEncode(categoryData));

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create category');
    }
  }

  Future<Map<String, dynamic>> updateCategory(int id, Map<String, dynamic> categoryData) async {
    final response = await http.put(Uri.parse('${ApiUrl.baseUrl}/categories/$id'), 
    headers: await getHeaders(),
    body: jsonEncode(categoryData));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update category');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse('${ApiUrl.baseUrl}/categories/$id'), 
    headers: await getHeaders());

    if (response.statusCode != 204) {
      throw Exception('Failed to delete category');
    }
  }
}