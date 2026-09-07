class GoalModel {
  final int id;
  final int userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String? description;
  final String? targetDate;
  final String? status;

  GoalModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.description,
    this.targetDate,
    this.status,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name']?.toString() ?? '',
      targetAmount:
          double.tryParse(json['target_amount']?.toString() ?? '') ?? 0.0,
      currentAmount:
          double.tryParse(json['current_amount']?.toString() ?? '') ?? 0.0,
      description: json['description']?.toString(),
      targetDate: json['target_date']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'description': description,
      'target_date': targetDate,
      'status': status,
    };
  }
}
