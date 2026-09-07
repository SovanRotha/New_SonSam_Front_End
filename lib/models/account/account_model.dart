import 'package:sansom/models/account/account_type_model.dart';

class AccountModel {
  final int id;
  final int userId;
  final int accountTypeId;
  final String name;
  final double balance;
  final String currency;
  final String? icon;
  final String? color;
  final String status;
  AccountTypeModel? accountType;

  AccountModel({
    required this.id,
    required this.userId,
    required this.accountTypeId,
    required this.name,
    required this.balance,
    required this.currency,
    this.icon,
    this.color,
    required this.status,
    this.accountType,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      accountTypeId: int.tryParse(json['account_type_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      icon: json['icon'],
      color: json['color'],
      status: json['status'] ?? 'active',
      accountType: json['account_type'] != null
          ? AccountTypeModel.fromJson(json['account_type'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_type_id': accountTypeId,
      'name': name,
      'balance': balance,
      'currency': currency,
      'icon': icon,
      'color': color,
      'status': status,
      'account_type': accountType?.toJson(),
    };
  }
}
