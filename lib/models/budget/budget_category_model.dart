
class BudgetCategory{
  // 'budget_id',
  //       'category_id',
  //       'limit_amount',
  //       'alert_percentage',
  //       'rollover_amount',

  int id;
  int budgetId;
  int categoryId;
  double limitAmount;
  double alertPercentage;
  double? rolloverAmount;

  BudgetCategory({
    required this.id,
    required this.budgetId,
    required this.categoryId,
    required this.limitAmount,
    required this.alertPercentage,
    this.rolloverAmount,
  });

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'] ?? 0,
      budgetId: json['budget_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      limitAmount: double.tryParse(json['limit_amount']?.toString() ?? '') ?? 0.0,
      alertPercentage: double.tryParse(json['alert_percentage']?.toString() ?? '') ?? 0.0,
      rolloverAmount: double.tryParse(json['rollover_amount']?.toString() ?? '') ?? 0.0,
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
    };
  }
}