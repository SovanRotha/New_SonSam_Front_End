
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/budget/budget_category_provider.dart';

class GetBudgetCategories extends StatelessWidget {
  const GetBudgetCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetCategoryProvider =
        context.watch<BudgetCategoryProvider>();

    final budgetCategories =
        budgetCategoryProvider.budgetCategories;

    // Loading
    if (budgetCategoryProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error
    if (budgetCategoryProvider.errorMessage != null) {
      return Center(
        child: Text(
          budgetCategoryProvider.errorMessage!,
        ),
      );
    }

    // Empty
    if (budgetCategories.isEmpty) {
      return const Center(
        child: Text(
          'No categories added to this budget yet.',
        ),
      );
    }

    return ListView.builder(
      itemCount: budgetCategories.length,
      itemBuilder: (context, index) {
        final budgetCategory =
            budgetCategories[index];

        return Card(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.category_outlined,
              ),
            ),

            title: Text(
              budgetCategory.category?.name ??
                  'Unknown Category',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Limit: \$${budgetCategory.limitAmount.toStringAsFixed(2)}',
              ),
            ),

            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${budgetCategory.alertPercentage}% Alert',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

