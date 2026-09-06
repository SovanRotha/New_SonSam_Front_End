
class BillModel {
  final int id;
  final int userId;
  final int accountId;
  final int? categoryId;
  final String name;
  final double amount;
  final String dueDate;
  final String status;
  final String? notes;

  BillModel({
    required this.id,
    required this.userId,
    required this.accountId,
    this.categoryId,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.notes,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      accountId: json['account_id'] ?? 0,
      categoryId: json['category_id'],
      name: json['name']?.toString() ?? '',
      amount: double.tryParse(
            json['amount']?.toString() ?? '',
          ) ??
          0.0,
      dueDate: json['due_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'upcoming',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'category_id': categoryId,
      'name': name,
      'amount': amount,
      'due_date': dueDate,
      'status': status,
      'notes': notes,
    };
  }
}