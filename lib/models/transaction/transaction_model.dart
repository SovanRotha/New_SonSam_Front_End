class TransactionModel {
  final int id;
  final int userId;
  final int accountId;
  final int categoryId;
  final String type; // 'income' or 'expense'
  final double amount;
  final String? description;
  final String transactionDate;
  final String status;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.description,
    required this.transactionDate,
    required this.status,
  });

  // Convert JSON response from Laravel API into a Dart object
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      accountId: json['account_id'] as int,
      categoryId: json['category_id'] as int,
      type: json['type']?.toString() ?? 'expense',
      // Convert database decimal/string values safely to double
      amount: double.parse(json['amount'].toString()),
      description: json['description']?.toString(),
      transactionDate: json['transaction_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'completed',
    );
  }

  // Convert Dart object back to JSON payload for POST/PUT requests
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'description': description,
      'transaction_date': transactionDate,
      'status': status,
    };
  }
}