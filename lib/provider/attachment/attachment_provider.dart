import 'package:flutter/foundation.dart';
import 'package:sansom/service/attachment/attachment_service.dart';

class AttachmentProvider extends ChangeNotifier {
  AttachmentService attachmentService = AttachmentService();

  List<Map<String, dynamic>> attachments = [];

  bool isLoading = false;

  String? errorMessage;

  // GET all attachments
  Future<void> getAttachments() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await attachmentService.getAttachments();

      final data = response['attachments'];

      if (data is List) {
        attachments = data
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else {
        attachments = [];
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // GET attachment by ID
  Future<Map<String, dynamic>?> getAttachment(int id) async {
    try {
      final response = await attachmentService.getAttachment(id);

      final data = response['attachment'];

      if (data != null) {
        return Map<String, dynamic>.from(data);
      }

      return null;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return null;
    }
  }

  // DELETE attachment
  Future<bool> deleteAttachment(int id) async {
    try {
      await attachmentService.deleteAttachment(id);

      attachments.removeWhere((attachment) => attachment['id'] == id);

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
