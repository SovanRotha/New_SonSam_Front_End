import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/budget/budget_provider.dart';

class EditBudget extends StatefulWidget {
  final int budgetId;
  final String name;
  final String month;
  final dynamic totalLimit;
  final bool rollover;
  final dynamic rolloverAmount;
  final String status;

  const EditBudget({
    super.key,
    required this.budgetId,
    required this.name,
    required this.month,
    required this.totalLimit,
    required this.rollover,
    required this.rolloverAmount,
    required this.status,
  });

  @override
  State<EditBudget> createState() => _EditBudgetState();
}

class _EditBudgetState extends State<EditBudget> {
  late TextEditingController nameController;
  late TextEditingController monthController;
  late TextEditingController totalLimitController;
  late TextEditingController rolloverAmountController;

  late bool rollover;
  late String status;

  final List<String> statuses = [
    'active',
    'inactive',
    'completed',
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    monthController = TextEditingController(text: widget.month);
    totalLimitController = TextEditingController(text: widget.totalLimit.toString());
    rolloverAmountController = TextEditingController(text: widget.rolloverAmount.toString());

    rollover = widget.rollover;
    status = widget.status;
  }

  @override
  void dispose() {
    nameController.dispose();
    monthController.dispose();
    totalLimitController.dispose();
    rolloverAmountController.dispose();
    super.dispose();
  }

  Future<void> updateBudget() async {
    final name = nameController.text.trim();
    final month = monthController.text.trim();

    final totalLimit = double.tryParse(
      totalLimitController.text.trim(),
    );

    final rolloverAmount = double.tryParse(
      rolloverAmountController.text.trim(),
    );

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter budget name')),
      );
      return;
    }

    if (month.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter month')),
      );
      return;
    }

    if (totalLimit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid total limit')),
      );
      return;
    }

    final data = {
      'name': name,
      'month': month,
      'total_limit': totalLimit,
      'rollover_enabled': rollover,
      'rollover_amount': rolloverAmount ?? 0,
      'status': status,
    };

    final provider = context.read<BudgetProvider>();
    final success = await provider.updateBudget(widget.budgetId, data);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to update budget'),
        ),
      );
    }
  }

  InputDecoration _buildInputDecoration({required String labelText, String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
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
    final provider = context.watch<BudgetProvider>();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Edit Budget',
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
              // Name
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(labelText: 'Budget Name'),
              ),

              const SizedBox(height: 14),

              // Month
              TextField(
                controller: monthController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  labelText: 'Month',
                  hintText: '2026-09-01',
                ),
              ),

              const SizedBox(height: 14),

              // Total Limit
              TextField(
                controller: totalLimitController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(labelText: 'Total Limit'),
              ),

              const SizedBox(height: 14),

              // Rollover Switch Box
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  title: const Text(
                    'Enable Rollover',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  value: rollover,
                  onChanged: (value) {
                    setState(() {
                      rollover = value;
                    });
                  },
                ),
              ),

              // Rollover Amount
              if (rollover) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: rolloverAmountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _buildInputDecoration(labelText: 'Rollover Amount'),
                ),
              ],

              const SizedBox(height: 14),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: status,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: _buildInputDecoration(labelText: 'Status'),
                items: statuses.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value[0].toUpperCase() + value.substring(1),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: provider.isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: provider.isLoading ? null : updateBudget,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: provider.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textLight,
                  ),
                )
              : const Text(
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