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
    this.autoCreate = false,
    this.status = 'active',
    this.account,
    this.category,
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'],
      accountId: json['account_id'],
      categoryId: json['category_id'],
      type: json['type'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'],
      frequency: json['frequency'],
      autoCreate: json['auto_create'] ?? false,
      status: json['status'] ?? 'active',
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
      'auto_create': autoCreate,
      'status': status,
      'account': account?.toJson(),
      'category': category?.toJson(),
    };
  }
}