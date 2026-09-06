class SubscriptionModel {
  final int id;
  final int userId;
  final int accountId;
  final int categoryId;
  final String name;
  final double amount;
  final String billingCycle;
  final String nextPaymentDate;
  final String startDate;
  final String? endDate;
  final String? status;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.nextPaymentDate,
    required this.startDate,
    this.endDate,
    this.status,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      accountId: json['account_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      name: json['name']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      billingCycle: json['billing_cycle']?.toString() ?? '',
      nextPaymentDate: json['next_payment_date']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'category_id': categoryId,
      'name': name,
      'amount': amount,
      'billing_cycle': billingCycle,
      'next_payment_date': nextPaymentDate,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
    };
  }
}
