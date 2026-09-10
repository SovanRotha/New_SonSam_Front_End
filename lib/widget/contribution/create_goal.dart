import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/goal/goal_provider.dart';

class CreateGoal extends StatefulWidget {
  const CreateGoal({super.key});

  @override
  State<CreateGoal> createState() => _CreateGoalState();
}

class _CreateGoalState extends State<CreateGoal> {
  final TextEditingController goalNameController = TextEditingController();
  final TextEditingController goalDescriptionController = TextEditingController();
  final TextEditingController goalTargetAmountController = TextEditingController();

  DateTime? selectedTargetDate;
  bool isCreating = false;

  @override
  void dispose() {
    goalNameController.dispose();
    goalDescriptionController.dispose();
    goalTargetAmountController.dispose();
    super.dispose();
  }

  // =========================
  // SELECT TARGET DATE
  // =========================
  Future<void> selectTargetDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textLight,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedTargetDate = pickedDate;
      });
    }
  }

  // =========================
  // CREATE GOAL
  // =========================
  Future<void> createGoal() async {
    final name = goalNameController.text.trim();
    final description = goalDescriptionController.text.trim();
    final targetAmount = goalTargetAmountController.text.trim();

    // Validate name
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal name')),
      );
      return;
    }

    // Validate target amount
    if (targetAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter target amount')),
      );
      return;
    }

    // Validate date
    if (selectedTargetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select target date')),
      );
      return;
    }

    setState(() {
      isCreating = true;
    });

    // Format date as YYYY-MM-DD
    final targetDate =
        '${selectedTargetDate!.year.toString().padLeft(4, '0')}-'
        '${selectedTargetDate!.month.toString().padLeft(2, '0')}-'
        '${selectedTargetDate!.day.toString().padLeft(2, '0')}';

    final goalData = {
      'name': name,
      'description': description.isEmpty ? null : description,
      'target_amount': double.parse(targetAmount),
      'target_date': targetDate,
      'status': 'active',
    };

    final goalProvider = context.read<GoalProvider>();
    final success = await goalProvider.createGoal(goalData);

    if (!mounted) return;

    setState(() {
      isCreating = false;
    });

    if (success) {
      await goalProvider.getGoals();

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal created successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            goalProvider.errorMessage ?? 'Failed to create goal',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title and close button row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Goal',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // =========================
              // GOAL NAME
              // =========================
              const Text(
                'Goal Name',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: goalNameController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: _inputDecoration(hintText: 'e.g., New Laptop, Vacation'),
              ),

              const SizedBox(height: 14),

              // =========================
              // DESCRIPTION
              // =========================
              const Text(
                'Description (Optional)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: goalDescriptionController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: _inputDecoration(hintText: 'Add some details about your goal...'),
              ),

              const SizedBox(height: 14),

              // =========================
              // TARGET AMOUNT
              // =========================
              const Text(
                'Target Amount',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: goalTargetAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: _inputDecoration(hintText: '0.00', prefixText: '\$ '),
              ),

              const SizedBox(height: 14),

              // =========================
              // TARGET DATE
              // =========================
              const Text(
                'Target Date',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: selectTargetDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: _inputDecoration(
                    hintText: 'Select target date',
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  child: Text(
                    selectedTargetDate == null
                        ? 'Select target date'
                        : '${selectedTargetDate!.year}-'
                            '${selectedTargetDate!.month.toString().padLeft(2, '0')}-'
                            '${selectedTargetDate!.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: selectedTargetDate == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // STATUS DISPLAY
              // =========================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Status: Active',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // =========================
              // CREATE BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCreating ? null : createGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textLight,
                          ),
                        )
                      : const Text(
                          'Create Goal',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
      ),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
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
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }
}