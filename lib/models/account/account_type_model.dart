class AccountTypeModel {
  final int id;
  final String name;
  final String? icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AccountTypeModel({
    required this.id,
    required this.name,
    this.icon,
    this.createdAt,
    this.updatedAt,
  });

  factory AccountTypeModel.fromJson(Map<String, dynamic> json) {
    return AccountTypeModel(
      id: json['id'],
      name: json['name'] ?? '',
      icon: json['icon'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}