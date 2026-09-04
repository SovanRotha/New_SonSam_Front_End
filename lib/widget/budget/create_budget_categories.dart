import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/budget/budget_category_provider.dart';
import 'package:sansom/provider/category/category_provider.dart';

class CreateBudgetCategories extends StatefulWidget {
  final int budgetId;

  const CreateBudgetCategories({
    super.key,
    required this.budgetId,
  });

  @override
  State<CreateBudgetCategories> createState() =>
      _CreateBudgetCategoriesState();
}

class _CreateBudgetCategoriesState
    extends State<CreateBudgetCategories> {
  int? selectedCategoryId;

  final TextEditingController limitAmountController =
      TextEditingController();

  final TextEditingController alertPercentageController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CategoryProvider>().getCategory();

      print(
        'Categories: '
        '${context.read<CategoryProvider>().categories.length}',
      );
    });
  }

  @override
  void dispose() {
    limitAmountController.dispose();
    alertPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetCategoryProvider =
        context.read<BudgetCategoryProvider>();

    final categoryProvider =
        context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Budget Category'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            const Text(
              'Add Category to Budget',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Set a spending limit and alert for this category.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),

            // CATEGORY
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<int>(
              value: selectedCategoryId,

              decoration: InputDecoration(
                hintText: 'Select a category',
                prefixIcon: const Icon(
                  Icons.category_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              items: categoryProvider.categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // LIMIT
            const Text(
              'Limit Amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: limitAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. 200.00',
                prefixIcon: const Icon(
                  Icons.account_balance_wallet_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ALERT PERCENTAGE
            const Text(
              'Alert Percentage',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: alertPercentageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 80',
                suffixText: '%',
                prefixIcon: const Icon(
                  Icons.notifications_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'You will be alerted when spending reaches this percentage.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 32),

            // BUTTONS
            Row(
              children: [

                // CANCEL
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),

                const SizedBox(width: 12),

                // SAVE
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedCategoryId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select a category',
                            ),
                          ),
                        );
                        return;
                      }

                      final limitAmount = double.tryParse(
                        limitAmountController.text,
                      );

                      final alertPercentage = double.tryParse(
                        alertPercentageController.text,
                      );

                      if (limitAmount == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a valid limit amount',
                            ),
                          ),
                        );
                        return;
                      }

                      if (alertPercentage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a valid alert percentage',
                            ),
                          ),
                        );
                        return;
                      }

                      final data = {
                        'budget_id': widget.budgetId,
                        'category_id': selectedCategoryId,
                        'limit_amount': limitAmount,
                        'alert_percentage': alertPercentage,
                      };

                      await budgetCategoryProvider
                          .createBudgetCategory(data);

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}