class NotificationModel {
  final int id;
  final int userId;
  final String? title;
  final String? message;
  final String? type;
  final String? readAt;
  final String? createdAt;
  final String? updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.title,
    this.message,
    this.type,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      type: json['type']?.toString(),
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'read_at': readAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isRead => readAt != null;
}
