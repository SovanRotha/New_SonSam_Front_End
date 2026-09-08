import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';

class AttachmentService {
  Future<Map<String, String>> getHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET ALL ATTACHMENTS
  Future<Map<String, dynamic>> getAttachments() async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/attachments'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load attachments: ${response.body}',
    );
  }

  // GET ONE ATTACHMENT
  Future<Map<String, dynamic>> getAttachment(int id) async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/attachments/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load attachment: ${response.body}',
    );
  }

  // DELETE ATTACHMENT
  Future<void> deleteAttachment(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/attachments/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to delete attachment: ${response.body}',
      );
    }
  }
}