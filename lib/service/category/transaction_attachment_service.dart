import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';

class TransactionAttachmentService {
  // Headers for normal JSON requests
  Future<Map<String, String>> getHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all attachments
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

  // Get one attachment
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

  // Upload attachment
  Future<Map<String, dynamic>> uploadAttachment({
    required int transactionId,
    required PlatformFile file,
  }) async {
    if (file.path == null) {
      throw Exception('File path is not available');
    }

    final token = await TokenStorage.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiUrl.baseUrl}/attachments'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // Send transaction ID
    request.fields['transaction_id'] = transactionId.toString();

    // Send file
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path!,
        filename: file.name,
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to upload attachment: ${response.body}',
    );
  }

  // Delete attachment
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

