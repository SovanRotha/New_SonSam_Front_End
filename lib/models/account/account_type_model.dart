import 'package:sansom/models/account/account_model.dart';

class AccountTypeModel {
  final int id;
  final String name;
  final String? icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  AccountModel? account;

  AccountTypeModel({
    required this.id,
    required this.name,
    this.icon,
    this.createdAt,
    this.updatedAt,
    this.account,
  });

  factory AccountTypeModel.fromJson(Map<String, dynamic> json) {
    final accountData = json['account'];
    final accountJson = accountData is Map<String, dynamic>
        ? accountData
        : accountData is List && accountData.isNotEmpty
        ? accountData.firstWhere(
            (item) => item is Map<String, dynamic>,
            orElse: () => null,
          )
        : null;

    return AccountTypeModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      icon: json['icon'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      account: accountJson is Map<String, dynamic>
          ? AccountModel.fromJson(accountJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'account': account?.toJson(),
    };
  }
}
