import 'package:flutter/foundation.dart';
import 'package:sansom/models/notification/notification_model.dart';
import 'package:sansom/service/notification/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationService notificationService = NotificationService();

  List<NotificationModel> notifications = [];

  bool isLoading = false;

  String? errorMessage;

  int get unreadCount {
    return notifications.where((notification) => !notification.isRead).length;
  }

  // =========================
  // GET ALL NOTIFICATIONS
  // =========================
  Future<void> getNotifications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await notificationService.getNotifications();

      final data = response['notifications'];

      if (data is List) {
        notifications = data
            .map(
              (json) =>
                  NotificationModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      } else {
        notifications = [];
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // =========================
  // GET UNREAD NOTIFICATIONS
  // =========================
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final response = await notificationService.getUnreadNotifications();

      final data = response['notifications'];

      if (data is List) {
        return data
            .map(
              (json) =>
                  NotificationModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      }

      return [];
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return [];
    }
  }

  // =========================
  // GET ONE NOTIFICATION
  // =========================
  Future<NotificationModel?> getNotification(int id) async {
    try {
      final response = await notificationService.getNotification(id);

      final data = response['notification'];

      if (data != null) {
        return NotificationModel.fromJson(Map<String, dynamic>.from(data));
      }

      return null;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return null;
    }
  }

  // =========================
  // MARK AS READ
  // =========================
  Future<bool> markAsRead(int id) async {
    try {
      final response = await notificationService.markAsRead(id);

      final data = response['notification'];

      if (data != null) {
        NotificationModel updatedNotification = NotificationModel.fromJson(
          Map<String, dynamic>.from(data),
        );

        int index = notifications.indexWhere(
          (notification) => notification.id == id,
        );

        if (index != -1) {
          notifications[index] = updatedNotification;
          notifyListeners();
        }
      }

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // =========================
  // MARK ALL AS READ
  // =========================
  Future<bool> markAllAsRead() async {
    try {
      await notificationService.markAllAsRead();

      await getNotifications();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // =========================
  // DELETE ONE
  // =========================
  Future<bool> deleteNotification(int id) async {
    try {
      await notificationService.deleteNotification(id);

      notifications.removeWhere((notification) => notification.id == id);

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // =========================
  // DELETE ALL
  // =========================
  Future<bool> deleteAllNotifications() async {
    try {
      await notificationService.deleteAllNotifications();

      notifications.clear();

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // =========================
  // CLEAR ERROR
  // =========================
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
