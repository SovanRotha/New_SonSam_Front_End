import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/contribution/contribution_provider.dart';
import 'package:sansom/provider/goal/goal_provider.dart';
import 'package:sansom/provider/transaction/transaction_provider.dart';

class CreateContribution extends StatefulWidget {
  final int? goalId;
  final String? goalName;

  const CreateContribution({
    super.key,
    this.goalId,
    this.goalName,
  });

  @override
  State<CreateContribution> createState() => _CreateContributionState();
}

class _CreateContributionState extends State<CreateContribution> {
  final formKey = GlobalKey<FormState>();

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  int? selectedTransactionId;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // Default to today's date so it isn't empty initially
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // =========================
  // SELECT DATE
  // =========================
  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
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
        selectedDate = pickedDate;
      });
    }
  }

  // =========================
  // FORMAT DATE
  // =========================
  String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // =========================
  // CREATE CONTRIBUTION
  // =========================
  Future<void> createContribution() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a contribution date')),
      );
      return;
    }

    if (widget.goalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving goal is required')),
      );
      return;
    }

    final contributionProvider = context.read<ContributionProvider>();

    final contributionData = {
      'saving_goal_id': widget.goalId,
      'transaction_id': selectedTransactionId,
      'amount': double.parse(amountController.text.trim()),
      'contribution': formatDate(selectedDate!),
      'note': noteController.text.trim().isEmpty
          ? null
          : noteController.text.trim(),
    };

    final success = await contributionProvider.createContribution(
      contributionData,
    );

    if (!mounted) return;

    if (success) {
      await context.read<GoalProvider>().refreshGoal(
            widget.goalId!,
          );

      if (!mounted) return;

      await contributionProvider.getContributions();

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contribution created successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            contributionProvider.errorMessage ?? 'Failed to create contribution',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final contributionProvider = context.watch<ContributionProvider>();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Create Contribution',
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
      content: SizedBox(
        width: 450,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // SAVING GOAL
                // =========================
                const Text(
                  'Saving Goal',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    widget.goalName?.isNotEmpty == true
                        ? widget.goalName!
                        : 'Goal #${widget.goalId}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // =========================
                // AMOUNT
                // =========================
                const Text(
                  'Amount',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: _inputDecoration(
                    hintText: '0.00',
                    prefixText: '\$ ',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null) {
                      return 'Please enter a valid amount';
                    }
                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // =========================
                // CONTRIBUTION DATE
                // =========================
                const Text(
                  'Contribution Date',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      hintText: 'Select date',
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    child: Text(
                      selectedDate == null
                          ? 'Select date'
                          : formatDate(selectedDate!),
                      style: TextStyle(
                        color: selectedDate == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // =========================
                // NOTE
                // =========================
                const Text(
                  'Note (Optional)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: _inputDecoration(
                    hintText: 'Add a note about this contribution...',
                  ),
                ),

                const SizedBox(height: 10),

                // =========================
                // TRANSACTION LOADING / ERROR
                // =========================
                if (transactionProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                if (transactionProvider.errorMessage != null)
                  Text(
                    transactionProvider.errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: contributionProvider.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: contributionProvider.isLoading
              ? null
              : createContribution,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: contributionProvider.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textLight,
                  ),
                )
              : const Text(
                  'Create',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
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