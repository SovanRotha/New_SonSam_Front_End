import 'package:sansom/models/account/account_model.dart';
import 'package:sansom/models/category/category_model.dart';

class SubscriptionModel {
  final int id;
  final int userId;
  final int accountId;
  final int categoryId;
  final String name;
  final double amount;
  final String billingCycle;
  final String? nextPaymentDate;
  final String startDate;
  final String? endDate;
  final String? status;
  AccountModel? account;
  Category? category;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.billingCycle,
    this.nextPaymentDate,
    required this.startDate,
    this.endDate,
    this.status,
    this.account,
    this.category,
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
      nextPaymentDate: json['next_payment_date']?.toString(),
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString(),
      status: json['status']?.toString(),
      account: json['account'] != null
          ? AccountModel.fromJson(json['account'])
          : null,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,

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
      'account': account?.toJson(),
      'category': category?.toJson(),
    };
  }
}
