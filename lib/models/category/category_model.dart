
import 'package:flutter/foundation.dart';

class Category{
  int id;
  String name;
  String type;
  int userId;
  int? parentId;
  String? icon;
  String? color;
  bool? isSystem;
  String? status;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.userId,
    this.parentId,
    this.icon,
    this.color,
    this.isSystem,
    this.status,
  });

  Future<Map<String, dynamic>> toJson() async {
    return {
      'id': id,
      'name': name,
      'type': type,
      'user_id': userId,
      'parent_id': parentId,
      'icon': icon,
      'color': color,
      'is_system': isSystem,
      'status': status,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      userId: json['user_id'] ?? 0,
      parentId: json['parent_id'],
      icon: json['icon'],
      color: json['color'],
      isSystem: json['is_system'],
      status: json['status'],
    );
  }
}