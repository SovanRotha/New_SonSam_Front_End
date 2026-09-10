import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/goal/goal_provider.dart';

class EditGoal extends StatefulWidget {
  final int goalId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String? description;
  final String targetDate;
  final String status;

  const EditGoal({
    super.key,
    required this.goalId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.description,
    required this.targetDate,
    required this.status,
  });

  @override
  State<EditGoal> createState() => _EditGoalState();
}

class _EditGoalState extends State<EditGoal> {
  late TextEditingController nameController;
  late TextEditingController targetAmountController;
  late TextEditingController descriptionController;
  late TextEditingController targetDateController;

  late String status;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    targetAmountController = TextEditingController(text: widget.targetAmount.toString());
    descriptionController = TextEditingController(text: widget.description ?? '');
    targetDateController = TextEditingController(text: widget.targetDate);

    status = widget.status;
  }

  @override
  void dispose() {
    nameController.dispose();
    targetAmountController.dispose();
    descriptionController.dispose();
    targetDateController.dispose();
    super.dispose();
  }

  Future<void> updateGoal() async {
    final name = nameController.text.trim();
    final targetAmount = double.tryParse(targetAmountController.text.trim());
    final description = descriptionController.text.trim();
    final targetDate = targetDateController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal name.')),
      );
      return;
    }

    if (targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target amount.')),
      );
      return;
    }

    if (targetDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a target date.')),
      );
      return;
    }

    final data = {
      'name': name,
      'target_amount': targetAmount,
      'description': description.isEmpty ? null : description,
      'target_date': targetDate,
      'status': status,
    };

    final success = await context.read<GoalProvider>().updateGoal(
          widget.goalId,
          data,
        );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Edit Goal',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Goal Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: _inputDecoration(hintText: 'e.g., New Laptop'),
            ),
            const SizedBox(height: 14),

            const Text('Target Amount', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: targetAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: _inputDecoration(hintText: '0.00', prefixText: '\$ '),
            ),
            const SizedBox(height: 14),

            const Text('Description (Optional)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: _inputDecoration(hintText: 'Add some details about your goal...'),
            ),
            const SizedBox(height: 14),

            const Text('Target Date', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: targetDateController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: _inputDecoration(
                hintText: 'YYYY-MM-DD',
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 14),

            const Text('Status', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: status,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: _inputDecoration(),
              items: const [
                DropdownMenuItem(
                  value: 'active',
                  child: Text('Active', style: TextStyle(color: AppColors.textPrimary)),
                ),
                DropdownMenuItem(
                  value: 'completed',
                  child: Text('Completed', style: TextStyle(color: AppColors.textPrimary)),
                ),
                DropdownMenuItem(
                  value: 'cancelled',
                  child: Text('Cancelled', style: TextStyle(color: AppColors.textPrimary)),
                ),
              ],
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: updateGoal,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('Update', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hintText, String? prefixText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
}