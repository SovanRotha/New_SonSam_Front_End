import 'package:sansom/models/account/account_model.dart';
import 'package:sansom/models/category/category_model.dart';

class RecurringTransaction {
  final int? id;
  final int accountId;
  final int? categoryId;
  final String type;
  final double amount;
  final String? description;
  final String frequency;
  final String startDate;
  final String? endDate;
  final bool autoCreate;
  final String status;
  AccountModel? account;
  Category? category;

 
  RecurringTransaction({
    this.id,
    required this.accountId,
    this.categoryId,
    required this.type,
    required this.amount,
    this.description,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.autoCreate = false,
    this.status = 'active',
    this.account,
    this.category,
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: int.tryParse(json['id']?.toString() ?? ''),
      accountId: int.tryParse(json['account_id']?.toString() ?? '') ?? 0,
      categoryId: int.tryParse(json['category_id']?.toString() ?? ''),
      type: json['type']?.toString() ?? 'expense',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      description: json['description'],
      frequency: json['frequency']?.toString() ?? 'monthly',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString(),
      autoCreate: json['auto_create'] is bool
          ? json['auto_create'] as bool
          : false,
      status: json['status']?.toString() ?? 'active',
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
      'id': id,
      'account_id': accountId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'description': description,
      'frequency': frequency,
      'start_date': startDate,
      'end_date': endDate,
      'auto_create': autoCreate,
      'status': status,
      'account': account?.toJson(),
      'category': category?.toJson(),
    };
  }
}