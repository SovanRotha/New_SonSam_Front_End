
class Budget {
  int id;
  int userId;
  String name;
  String month;
  double totalLimit;
  bool rollover;
  double rolloverAmount;
  String? status;

  Budget({
    required this.id,
    required this.userId,
    required this.name,
    required this.month,
    required this.totalLimit,
    required this.rollover,
    required this.rolloverAmount,
    required this.status,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      month: json['month'] ?? '',
      totalLimit: double.tryParse(json['total_limit']?.toString() ?? '') ?? 0.0,
      rollover: json['rollover_enabled'] ?? false,
      rolloverAmount: double.tryParse(json['rollover_amount']?.toString() ?? '') ?? 0.0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'month': month,
      'total_limit': totalLimit,
      'rollover_enabled': rollover,
      'rollover_amount': rolloverAmount,
      'status': status,
    };
  }
}