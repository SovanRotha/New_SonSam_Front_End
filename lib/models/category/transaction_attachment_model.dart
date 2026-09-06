class TransactionAttachment {
  final int? id;
  final int transactionId;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;

  TransactionAttachment({
    this.id,
    required this.transactionId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,

  });

  factory TransactionAttachment.fromJson(Map<String, dynamic> json) {
    return TransactionAttachment(
      id: json['id'],
      transactionId: json['transaction_id'],
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'] ?? '',
      fileType: json['file_type'] ?? '',
      fileSize: json['file_size'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize
    };
  }

  // Check whether the attachment is an image
  bool get isImage => fileType.startsWith('image/');

  // Check whether the attachment is a PDF
  bool get isPdf => fileType == 'application/pdf';

  // Get file extension
  String get extension {
    final index = fileName.lastIndexOf('.');
    return index != -1 ? fileName.substring(index + 1) : '';
  }

  // Convert bytes to readable size
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    }

    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    }

    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
