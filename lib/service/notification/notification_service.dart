import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';

class NotificationService {
  // =========================
  // HEADERS
  // =========================
  Future<Map<String, String>> getHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // =========================
  // GET ALL NOTIFICATIONS
  // GET /notifications
  // =========================
  Future<Map<String, dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/notifications'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load notifications: ${response.body}',
    );
  }

  // =========================
  // GET UNREAD NOTIFICATIONS
  // GET /notifications/unread
  // =========================
  Future<Map<String, dynamic>> getUnreadNotifications() async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/notifications/unread'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load unread notifications: ${response.body}',
    );
  }

  // =========================
  // GET ONE NOTIFICATION
  // GET /notifications/{id}
  // =========================
  Future<Map<String, dynamic>> getNotification(int id) async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/notifications/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load notification: ${response.body}',
    );
  }

  // =========================
  // MARK AS READ
  // PATCH /notifications/{id}/read
  // =========================
  Future<Map<String, dynamic>> markAsRead(int id) async {
    final response = await http.patch(
      Uri.parse(
        '${ApiUrl.baseUrl}/notifications/$id/read',
      ),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to mark notification as read: ${response.body}',
    );
  }

  // =========================
  // MARK ALL AS READ
  // PATCH /notifications/read-all
  // =========================
  Future<Map<String, dynamic>> markAllAsRead() async {
    final response = await http.patch(
      Uri.parse(
        '${ApiUrl.baseUrl}/notifications/read-all',
      ),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to mark all notifications as read: ${response.body}',
    );
  }

  // =========================
  // DELETE ONE
  // DELETE /notifications/{id}
  // =========================
  Future<void> deleteNotification(int id) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiUrl.baseUrl}/notifications/$id',
      ),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to delete notification: ${response.body}',
      );
    }
  }

  // =========================
  // DELETE ALL
  // DELETE /notifications
  // =========================
  Future<void> deleteAllNotifications() async {
    final response = await http.delete(
      Uri.parse(
        '${ApiUrl.baseUrl}/notifications',
      ),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to delete all notifications: ${response.body}',
      );
    }
  }
}