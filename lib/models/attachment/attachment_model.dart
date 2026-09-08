
class AttachmentModel {
  final int id;
  final int? transactionId;
  final String? fileName;
  final String? filePath;
  final String? fileType;
  final String? createdAt;
  final String? updatedAt;

  AttachmentModel({
    required this.id,
    this.transactionId,
    this.fileName,
    this.filePath,
    this.fileType,
    this.createdAt,
    this.updatedAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'],
      fileName: json['file_name']?.toString(),
      filePath: json['file_path']?.toString(),
      fileType: json['file_type']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
