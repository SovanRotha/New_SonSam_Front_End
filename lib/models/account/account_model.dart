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
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      userId: json['user_id'],
      accountTypeId: json['account_type_id'],
      name: json['name'] ?? '',
      balance: double.tryParse(
            json['balance'].toString(),
          ) ??
          0.0,
      currency: json['currency'] ?? 'USD',
      icon: json['icon'],
      color: json['color'],
      status: json['status'] ?? 'active',

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
    };
  }
}

