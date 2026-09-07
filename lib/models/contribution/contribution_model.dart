
import 'package:sansom/models/goal/goal_model.dart';

class ContributionModel {
  final int id;
  final int userId;
  final int goalId;
  final double amount;
  final String? note;
  final String? contributionDate;
  GoalModel? goal;

  ContributionModel({
    required this.id,
    required this.userId,
    required this.goalId,
    required this.amount,
    this.note,
    this.contributionDate,
    this.goal,
  });

  factory ContributionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ContributionModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      goalId: json['goal_id'] ?? 0,
      amount: double.tryParse(
            json['amount']?.toString() ?? '',
          ) ??
          0.0,
      note: json['note']?.toString(),
      contributionDate:
          json['contribution_date']?.toString(),
      goal: json['goal'] != null
          ? GoalModel.fromJson(json['goal'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goal_id': goalId,
      'amount': amount,
      'note': note,
      'contribution_date': contributionDate,
      'goal': goal?.toJson(),
    };
  }
}
