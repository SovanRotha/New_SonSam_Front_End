// import 'package:flutter_test/flutter_test.dart';
// import 'package:sansom/provider/budget/budget_provider.dart';
// import 'package:sansom/service/budget/budget_service.dart';

// class FakeBudgetService extends BudgetService {
//   @override
//   Future<Map<String, dynamic>> createBudget(
//     Map<String, dynamic> budgetData,
//   ) async {
//     return {
//       'id': 7,
//       'user_id': 11,
//       'name': 'Groceries',
//       'month': 'September',
//       'total_limit': 800,
//       'rollover_enabled': true,
//       'rollover_amount': 50.0,
//       'status': 'active',
//     };
//   }
// }

// void main() {
//   test('createBudget stores the created budget', () async {
//     final provider = BudgetProvider(budgetService: FakeBudgetService());

//     final success = await provider.createBudget({
//       'name': 'Groceries',
//       'month': 'September',
//       'total_limit': 800,
//       'rollover_enabled': true,
//       'rollover_amount': 50.0,
//       'status': 'active',
//     });

//     expect(success, isTrue);
//     expect(provider.budget, isNotNull);
//     expect(provider.budget!.name, 'Groceries');
//     expect(provider.budget!.status, 'active');
//   });
// }
