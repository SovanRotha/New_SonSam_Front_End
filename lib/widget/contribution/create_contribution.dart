
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sansom/provider/contribution/contribution_provider.dart';
import 'package:sansom/provider/goal/goal_provider.dart';
import 'package:sansom/provider/transaction/transaction_provider.dart';

class CreateContribution extends StatefulWidget {
  final int? goalId;
  final String? goalName;

  CreateContribution({
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

    // No need to call GoalProvider().getGoals() here.
    //
    // We already know:
    // widget.goalId
    // widget.goalName
    //
    // The goal will be refreshed after creating
    // the contribution.
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
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate date
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a contribution date'),
        ),
      );
      return;
    }

    // Validate goal ID
    if (widget.goalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saving goal is required'),
        ),
      );
      return;
    }

    final contributionProvider =
        context.read<ContributionProvider>();

    // =========================
    // CONTRIBUTION DATA
    // =========================
    final contributionData = {
      'saving_goal_id': widget.goalId,
      'transaction_id': selectedTransactionId,
      'amount': double.parse(amountController.text.trim()),
      'contribution': formatDate(selectedDate!),
      'note': noteController.text.trim().isEmpty
          ? null
          : noteController.text.trim(),
    };

    // =========================
    // CREATE CONTRIBUTION
    // =========================
    final success =
        await contributionProvider.createContribution(
      contributionData,
    );

    if (!mounted) return;

    // =========================
    // SUCCESS
    // =========================
    if (success) {
      // IMPORTANT:
      //
      // The Laravel backend should update
      // current_amount when the contribution is created.
      //
      // Therefore, DO NOT call addMoney() here.
      //
      // Instead, fetch the latest goal from Laravel.
      await context.read<GoalProvider>().refreshGoal(
        widget.goalId!,
      );

      if (!mounted) return;

      // Refresh contribution list
      await contributionProvider.getContributions();

      if (!mounted) return;

      // Close dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Contribution created successfully',
          ),
        ),
      );
    }

    // =========================
    // ERROR
    // =========================
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            contributionProvider.errorMessage ??
                'Failed to create contribution',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider =
        context.watch<TransactionProvider>();

    final contributionProvider =
        context.watch<ContributionProvider>();

    return AlertDialog(
      title: const Text('Create Contribution'),

      content: SizedBox(
        width: 450,

        child: Form(
          key: formKey,

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // =========================
                // SAVING GOAL
                // =========================
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Saving Goal',
                    border: OutlineInputBorder(),
                  ),

                  child: Text(
                    widget.goalName?.isNotEmpty == true
                        ? widget.goalName!
                        : 'Goal #${widget.goalId}',
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // TRANSACTION
                // =========================
                //
                // Currently disabled.
                //
                // You can enable this later if
                // you want to connect a contribution
                // to a transaction.
                //
                // DropdownButtonFormField<int?>(
                //   value: selectedTransactionId,
                //
                //   decoration: const InputDecoration(
                //     labelText: 'Transaction',
                //     border: OutlineInputBorder(),
                //   ),
                //
                //   hint: const Text('No transaction'),
                //
                //   items: [
                //     const DropdownMenuItem<int?>(
                //       value: null,
                //       child: Text('No transaction'),
                //     ),
                //
                //     ...transactionProvider.transactions.map(
                //       (transaction) {
                //         return DropdownMenuItem<int?>(
                //           value: transaction.id,
                //           child: Text(
                //             'Transaction #${transaction.id}',
                //           ),
                //         );
                //       },
                //     ),
                //   ],
                //
                //   onChanged: (value) {
                //     setState(() {
                //       selectedTransactionId = value;
                //     });
                //   },
                // ),

                // =========================
                // AMOUNT
                // =========================
                TextFormField(
                  controller: amountController,

                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter contribution amount',
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }

                    final amount =
                        double.tryParse(value.trim());

                    if (amount == null) {
                      return 'Please enter a valid amount';
                    }

                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =========================
                // CONTRIBUTION DATE
                // =========================
                InkWell(
                  onTap: selectDate,

                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Contribution Date',
                      border: OutlineInputBorder(),
                      suffixIcon:
                          Icon(Icons.calendar_today),
                    ),

                    child: Text(
                      selectedDate == null
                          ? 'Select date'
                          : formatDate(selectedDate!),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // NOTE
                // =========================
                TextFormField(
                  controller: noteController,

                  maxLines: 3,

                  decoration: const InputDecoration(
                    labelText: 'Note',
                    hintText: 'Optional note',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                // =========================
                // TRANSACTION LOADING
                // =========================
                if (transactionProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8),

                    child: CircularProgressIndicator(),
                  ),

                // =========================
                // TRANSACTION ERROR
                // =========================
                if (transactionProvider.errorMessage != null)
                  Text(
                    transactionProvider.errorMessage!,

                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),

      // =========================
      // ACTION BUTTONS
      // =========================
      actions: [

        // CANCEL
        TextButton(
          onPressed: contributionProvider.isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                },

          child: const Text('Cancel'),
        ),

        // CREATE
        ElevatedButton(
          onPressed: contributionProvider.isLoading
              ? null
              : createContribution,

          child: contributionProvider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,

                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}

