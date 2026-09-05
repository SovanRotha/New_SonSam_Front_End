
class AIConversation {
  final int id;
  final int userId;
  final String title;

  AIConversation({
    required this.id,
    required this.userId,
    required this.title,
  });

  factory AIConversation.fromJson(Map<String, dynamic> json) {
    return AIConversation(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      title: json['title']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<Map<String, dynamic>> toJson() async {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
    };
  }
}