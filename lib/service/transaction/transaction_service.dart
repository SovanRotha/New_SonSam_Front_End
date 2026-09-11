
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';

import 'package:sansom/models/transaction/transaction_model.dart';

class TransactionService {
  
  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Fetch list of transactions
  Future<List<TransactionModel>> fetchTransactions(String token) async {
    final Uri url = Uri.parse('${ApiUrl.baseUrl}/transactions');
    final Map<String, String> headers = _getHeaders(token);

    // print('--> GET $url');

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      // print('<-- Status Code: ${response.statusCode}');
      // print('<-- Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);

        List<dynamic> data;

        if (jsonResponse is Map<String, dynamic>) {
          data = jsonResponse['transactions'] ?? [];
        } else if (jsonResponse is List) {
          data = jsonResponse;
        } else {
          throw Exception('Invalid response format');
        }

        return data
            .map(
              (item) => TransactionModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      Map<String, dynamic>? errorResponse;

      try {
        errorResponse = jsonDecode(response.body);
      } catch (_) {}

      throw Exception(
        errorResponse?['message'] ??
            'Failed to load transactions (${response.statusCode})',
      );
    } catch (e) {
      // print(' Error in fetchTransactions: $e');
      rethrow;
    }
  }

  // Create a new transaction
  Future<bool> createTransaction(
    String token,
    TransactionModel transaction,
  ) async {
    final Uri url = Uri.parse('${ApiUrl.baseUrl}/transactions');
    final Map<String, String> headers = _getHeaders(token);
    final String body = jsonEncode(transaction.toJson());

    // print('--> TOKEN: $token');
    // print('--> POST $url');
    // print('--> Request Body: $body');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // print('<-- Status Code: ${response.statusCode}');
      // print('<-- Response Body: ${response.body}');

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return true;
      }

      Map<String, dynamic>? errorResponse;

      try {
        errorResponse = jsonDecode(response.body);
      } catch (_) {}

      throw Exception(
        errorResponse?['message'] ??
            'Failed to create transaction (${response.statusCode})',
      );
    } catch (e) {
      // print(' Error in createTransaction: $e');
      rethrow;
    }
  }
}
