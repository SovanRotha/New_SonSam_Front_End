import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sansom/models/category/transaction_attachment_model.dart';
import 'package:sansom/service/category/transaction_attachment_service.dart';



class TransactionAttachmentProvider extends ChangeNotifier {
  TransactionAttachmentService service =
      TransactionAttachmentService();

  List<TransactionAttachment> attachments = [];

  bool isLoading = false;

  String? error;

  // Get all attachments
  Future<void> fetchAttachments() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await service.getAttachments();

      final data = response['attachments'] ?? [];

      attachments = (data as List)
          .map(
            (json) => TransactionAttachment.fromJson(json),
          )
          .toList();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Get attachments for a specific transaction
  List<TransactionAttachment> getByTransactionId(
    int transactionId,
  ) {
    return attachments
        .where(
          (attachment) =>
              attachment.transactionId == transactionId,
        )
        .toList();
  }

  // Upload attachment
  Future<bool> uploadAttachment({
    required int transactionId,
    required PlatformFile file,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await service.uploadAttachment(
        transactionId: transactionId,
        file: file,
      );

      final data = response['attachment'];

      if (data != null) {
        attachments.add(
          TransactionAttachment.fromJson(data),
        );
      }

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Delete attachment
  Future<bool> deleteAttachment(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await service.deleteAttachment(id);

      attachments.removeWhere(
        (attachment) => attachment.id == id,
      );

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    error = null;
    notifyListeners();
  }
}

