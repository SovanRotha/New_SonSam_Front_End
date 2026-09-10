import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/budget/budget_category_provider.dart';

class EditBudgetCategory extends StatefulWidget {
  final int budgetCategoryId;
  final String categoryName;
  final double limitAmount;
  final double alertPercentage;

  const EditBudgetCategory({
    super.key,
    required this.budgetCategoryId,
    required this.categoryName,
    required this.limitAmount,
    required this.alertPercentage,
  });

  @override
  State<EditBudgetCategory> createState() => _EditBudgetCategoryState();
}

class _EditBudgetCategoryState extends State<EditBudgetCategory> {
  late TextEditingController limitController;
  late TextEditingController alertController;

  @override
  void initState() {
    super.initState();

    limitController = TextEditingController(
      text: widget.limitAmount.toString(),
    );

    alertController = TextEditingController(
      text: widget.alertPercentage.toString(),
    );
  }

  @override
  void dispose() {
    limitController.dispose();
    alertController.dispose();
    super.dispose();
  }

  Future<void> updateBudgetCategory() async {
    final limit = double.tryParse(limitController.text.trim());
    final alertPercentage = double.tryParse(alertController.text.trim());

    if (limit == null || limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid limit amount.'),
        ),
      );
      return;
    }

    if (alertPercentage == null ||
        alertPercentage < 0 ||
        alertPercentage > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alert percentage must be between 0 and 100.'),
        ),
      );
      return;
    }

    final data = {
      'limit_amount': limit,
      'alert_percentage': alertPercentage,
    };

    final success = await context
        .read<BudgetCategoryProvider>()
        .updateBudgetCategory(
          widget.budgetCategoryId,
          data,
        );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    }
  }

  InputDecoration _buildInputDecoration({required String labelText, String? prefixText, String? suffixText}) {
    return InputDecoration(
      labelText: labelText,
      prefixText: prefixText,
      suffixText: suffixText,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      prefixStyle: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      suffixStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Edit Budget Category',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Title Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.categoryName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Limit Amount Input
              TextField(
                controller: limitController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  labelText: 'Limit Amount',
                  prefixText: '\$ ',
                ),
              ),

              const SizedBox(height: 16),

              // Alert Percentage Input
              TextField(
                controller: alertController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  labelText: 'Alert Percentage',
                  suffixText: '%',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: updateBudgetCategory,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text(
            'Update',
            style: TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}