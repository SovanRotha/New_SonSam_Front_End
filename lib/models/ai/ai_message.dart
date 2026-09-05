
class AIMessage {
  final int id;
  final int conversationId;
  final String role;
  final String message;
  final String? metadata;
  final String? toolCallId;

  AIMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.message,
    this.metadata,
    this.toolCallId,
  });

  factory AIMessage.fromJson(Map<String, dynamic> json) {
    return AIMessage(
      id: _parseInt(json['id']),
      conversationId: _parseInt(json['conversation_id']),
      role: json['role']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      metadata: json['metadata']?.toString(),
      toolCallId: json['tool_call_id']?.toString(),
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
      'conversation_id': conversationId,
      'role': role,
      'message': message,
      'metadata': metadata,
      'tool_call_id': toolCallId,
    };
  }
}