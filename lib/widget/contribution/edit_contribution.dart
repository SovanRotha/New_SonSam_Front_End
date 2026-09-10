import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/contribution/contribution_provider.dart';

class EditContribution extends StatefulWidget {
  final int contributionId;
  final double amount;
  final String? note;
  final String contributionDate;

  const EditContribution({
    super.key,
    required this.contributionId,
    required this.amount,
    required this.note,
    required this.contributionDate,
  });

  @override
  State<EditContribution> createState() => _EditContributionState();
}

class _EditContributionState extends State<EditContribution> {
  late TextEditingController amountController;
  late TextEditingController noteController;
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();

    amountController = TextEditingController(
      text: widget.amount.toString(),
    );

    noteController = TextEditingController(
      text: widget.note ?? '',
    );

    dateController = TextEditingController(
      text: widget.contributionDate,
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    dateController.dispose();

    super.dispose();
  }

  Future<void> updateContribution() async {
    final amount = double.tryParse(
      amountController.text.trim(),
    );

    final note = noteController.text.trim();
    final date = dateController.text.trim();

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount.'),
        ),
      );
      return;
    }

    if (date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a contribution date.'),
        ),
      );
      return;
    }

    final data = {
      'amount': amount,
      'note': note.isEmpty ? null : note,
      'contribution_date': date,
    };

    final success = await context
        .read<ContributionProvider>()
        .updateContribution(
          widget.contributionId,
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
        'Edit Contribution',
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
            const Text(
              'Amount',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: _inputDecoration(
                hintText: '0.00',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              'Note (Optional)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: noteController,
              maxLines: 3,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: _inputDecoration(
                hintText: 'Add a note about this contribution...',
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              'Contribution Date',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: dateController,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: _inputDecoration(
                hintText: 'YYYY-MM-DD',
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: updateContribution,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
          child: const Text(
            'Update',
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