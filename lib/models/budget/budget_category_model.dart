
import 'package:sansom/models/budget/budget_model.dart';
import 'package:sansom/models/category/category_model.dart';

class BudgetCategory{

  int id;
  int budgetId;
  int categoryId;
  double limitAmount;
  double? alertPercentage;
  double? rolloverAmount;
  final Category? category;
  final Budget? budget;

  BudgetCategory({
    required this.id,
    required this.budgetId,
    required this.categoryId,
    required this.limitAmount,
    this.alertPercentage,
    this.rolloverAmount,
    this.category,
    this.budget,
  });

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'] ?? 0,
      budgetId: json['budget_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      limitAmount: double.tryParse(json['limit_amount']?.toString() ?? '') ?? 0.0,
      alertPercentage: double.tryParse(json['alert_percentage']?.toString() ?? '') ?? 0.0,
      rolloverAmount: double.tryParse(json['rollover_amount']?.toString() ?? '') ?? 0.0,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      budget: json['budget'] != null ? Budget.fromJson(json['budget']) : null,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'budget_id': budgetId,
      'category_id': categoryId,
      'limit_amount': limitAmount,
      'alert_percentage': alertPercentage,
      'rollover_amount': rolloverAmount,
      'category': category?.toJson(),
      'budget': budget?.toJson(),
    };
  }
}