import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sansom/models/transaction/transaction_model.dart';
import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/account/account_type_provider.dart';
import 'package:sansom/provider/category/category_provider.dart';
import 'package:sansom/provider/transaction/transaction_provider.dart';
import 'package:sansom/service/token/token_storage.dart';
// import 'package:sansom/provider/category/category_provider.dart';
// import 'package:sansom/provider/transaction/transaction_provider.dart';

class CreateTransaction extends StatefulWidget {
  const CreateTransaction({super.key});

  @override
  State<CreateTransaction> createState() => _CreateTransactionState();
}

class _CreateTransactionState extends State<CreateTransaction> {
  int? selectedAccountId;
  int? selectedCategoryId;
  String? selectedType;

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final transactionDateController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AccountProvider>().getAccounts();
      context.read<CategoryProvider>().getCategory();
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    transactionDateController.dispose();
    notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final accountTypes = context.watch<AccountTypeProvider>().accountTypes;
    final categoryProvider = context.watch<CategoryProvider>();
    final accountIds = accountProvider.accountModel
        .map((account) => account.id)
        .toSet();
    final categoryIds = categoryProvider.categories
        .map((category) => category.id)
        .toSet();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // =========================
          // ACCOUNT
          // =========================
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Account',
              border: OutlineInputBorder(),
            ),

            value: accountIds.contains(selectedAccountId)
                ? selectedAccountId
                : null,

            items: accountProvider.accountModel
                .where((account) => accountIds.contains(account.id))
                .map((account) {
                  return DropdownMenuItem<int>(
                    value: account.id,
                    child: Text(
                      account.name +
                          ' (${accountTypes.firstWhere((type) => type.id == account.accountTypeId).name})',
                    ),
                  );
                })
                .toList(),

            onChanged: (value) {
              setState(() {
                selectedAccountId = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // =========================
          // CATEGORY
          // =========================
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),

            value: categoryIds.contains(selectedCategoryId)
                ? selectedCategoryId
                : null,

            items: categoryProvider.categories
                .where((category) => categoryIds.contains(category.id))
                .map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  );
                })
                .toList(),

            onChanged: (value) {
              setState(() {
                selectedCategoryId = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // =========================
          // TYPE
          // =========================
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),

            value: selectedType,

            items: const [
              DropdownMenuItem(value: 'income', child: Text('Income')),
              DropdownMenuItem(value: 'expense', child: Text('Expense')),
            ],

            onChanged: (value) {
              setState(() {
                selectedType = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // =========================
          // AMOUNT
          // =========================
          TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),

          const SizedBox(height: 16),

          // =========================
          // DESCRIPTION
          // =========================
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // =========================
          // DATE
          // =========================
          TextField(
            controller: transactionDateController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Transaction Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                setState(() {
                  transactionDateController.text =
                      '${pickedDate.year}-'
                      '${pickedDate.month.toString().padLeft(2, '0')}-'
                      '${pickedDate.day.toString().padLeft(2, '0')}';
                });
              }
            },
          ),

          const SizedBox(height: 16),

          // =========================
          // NOTES
          // =========================
          TextField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 24),

          // =========================
          // BUTTONS
          // =========================
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    submitTransaction();
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> submitTransaction() async {
    if (selectedAccountId == null) {
      showError('Please select an account');
      return;
    }

    if (selectedCategoryId == null) {
      showError('Please select a category');
      return;
    }

    if (selectedType == null) {
      showError('Please select transaction type');
      return;
    }

    if (amountController.text.isEmpty) {
      showError('Please enter amount');
      return;
    }

    if (transactionDateController.text.isEmpty) {
      showError('Please enter transaction date');
      return;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null) {
      showError('Please enter a valid amount');
      return;
    }

    final token = await TokenStorage.getToken();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      showError('You are not signed in');
      return;
    }

    final transaction = TransactionModel(
      id: 0,
      userId: 0,
      accountId: selectedAccountId!,
      categoryId: selectedCategoryId!,
      type: selectedType!,
      amount: amount,
      description: descriptionController.text.trim(),
      transactionDate: transactionDateController.text.trim(),
      status: 'completed',
    );

    final success = await context.read<TransactionProvider>().addTransaction(
      token,
      transaction,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      final errorMessage = context.read<TransactionProvider>().errorMessage;
      showError(errorMessage ?? 'Failed to create transaction');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
