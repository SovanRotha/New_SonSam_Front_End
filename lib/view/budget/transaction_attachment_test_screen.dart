import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/models/category/transaction_attachment_model.dart';
import 'package:sansom/provider/category/transaction_attachment_provider.dart';

class TransactionAttachmentTestScreen extends StatefulWidget {
  const TransactionAttachmentTestScreen({super.key});

  @override
  State<TransactionAttachmentTestScreen> createState() =>
      _TransactionAttachmentTestScreenState();
}

class _TransactionAttachmentTestScreenState
    extends State<TransactionAttachmentTestScreen> {
  final TextEditingController transactionIdController = TextEditingController();

  PlatformFile? selectedFile;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionAttachmentProvider>().fetchAttachments();
    });
  }

  @override
  void dispose() {
    transactionIdController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.pickFile(type: FileType.any);

      if (result != null) {
        setState(() {
          selectedFile = result;
        });
      }
    } catch (e) {
      showMessage('Failed to select file: $e', isError: true);
    }
  }

  // ==============================
  // UPLOAD FILE
  // ==============================
  Future<void> uploadFile() async {
    final transactionId = int.tryParse(transactionIdController.text.trim());

    if (transactionId == null) {
      showMessage('Please enter a valid transaction ID.', isError: true);
      return;
    }

    if (selectedFile == null) {
      showMessage('Please select a file first.', isError: true);
      return;
    }

    final provider = context.read<TransactionAttachmentProvider>();

    final success = await provider.uploadAttachment(
      transactionId: transactionId,
      file: selectedFile!,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        selectedFile = null;
      });

      showMessage('File uploaded successfully.');
    } else {
      showMessage(provider.error ?? 'Upload failed.', isError: true);
    }
  }

  // ==============================
  // DELETE FILE
  // ==============================
  Future<void> deleteFile(TransactionAttachment attachment) async {
    if (attachment.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Attachment'),
          content: Text(
            'Are you sure you want to delete "${attachment.fileName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final provider = context.read<TransactionAttachmentProvider>();

    final success = await provider.deleteAttachment(attachment.id!);

    if (!mounted) return;

    if (success) {
      showMessage('Attachment deleted successfully.');
    } else {
      showMessage(
        provider.error ?? 'Failed to delete attachment.',
        isError: true,
      );
    }
  }

  // ==============================
  // REFRESH
  // ==============================
  Future<void> refreshAttachments() async {
    await context.read<TransactionAttachmentProvider>().fetchAttachments();
  }

  // ==============================
  // MESSAGE
  // ==============================
  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ==============================
  // FILE ICON
  // ==============================
  IconData getFileIcon(TransactionAttachment attachment) {
    if (attachment.isImage) {
      return Icons.image;
    }

    if (attachment.isPdf) {
      return Icons.picture_as_pdf;
    }

    switch (attachment.extension.toLowerCase()) {
      case 'doc':
      case 'docx':
        return Icons.description;

      case 'xls':
      case 'xlsx':
        return Icons.table_chart;

      case 'ppt':
      case 'pptx':
        return Icons.slideshow;

      case 'zip':
      case 'rar':
        return Icons.folder_zip;

      default:
        return Icons.insert_drive_file;
    }
  }

  // ==============================
  // BUILD
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Attachments'),
        actions: [
          IconButton(
            onPressed: refreshAttachments,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),

      body: Consumer<TransactionAttachmentProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: refreshAttachments,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ==========================
                // TRANSACTION ID
                // ==========================
                TextField(
                  controller: transactionIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Transaction ID',
                    hintText: 'Enter transaction ID',
                    prefixIcon: const Icon(Icons.receipt_long),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==========================
                // SELECT FILE
                // ==========================
                OutlinedButton.icon(
                  onPressed: provider.isLoading ? null : pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Choose File'),
                ),

                const SizedBox(height: 12),

                // ==========================
                // SELECTED FILE
                // ==========================
                if (selectedFile != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file, size: 32),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedFile!.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  formatFileSize(
                                    selectedFile!.lengthSync() ?? 0,
                                  ),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              setState(() {
                                selectedFile = null;
                              });
                            },
                            icon: const Icon(Icons.close, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // ==========================
                // UPLOAD BUTTON
                // ==========================
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : uploadFile,
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      provider.isLoading ? 'Uploading...' : 'Upload File',
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==========================
                // TITLE
                // ==========================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attachments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      '${provider.attachments.length} files',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==========================
                // ERROR
                // ==========================
                if (provider.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            provider.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                        IconButton(
                          onPressed: provider.clearError,
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  ),

                // ==========================
                // LOADING
                // ==========================
                if (provider.isLoading && provider.attachments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: CircularProgressIndicator()),
                  )
                // ==========================
                // EMPTY
                // ==========================
                else if (provider.attachments.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 60,
                          color: Colors.grey[400],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'No attachments found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                // ==========================
                // ATTACHMENT LIST
                // ==========================
                else
                  ...provider.attachments.map((attachment) {
                    return buildAttachmentCard(attachment);
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==============================
  // ATTACHMENT CARD
  // ==============================
  Widget buildAttachmentCard(TransactionAttachment attachment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Icon(getFileIcon(attachment))),

        title: Text(
          attachment.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text('Transaction #${attachment.transactionId}'),

            Text(
              '${attachment.extension.toUpperCase()} • '
              '${attachment.formattedFileSize}',
            ),
          ],
        ),

        trailing: IconButton(
          onPressed: () {
            deleteFile(attachment);
          },
          icon: const Icon(Icons.delete_outline, color: Colors.red),
        ),
      ),
    );
  }

  // ==============================
  // FILE SIZE
  // ==============================
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
