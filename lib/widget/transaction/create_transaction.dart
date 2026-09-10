import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/models/transaction/transaction_model.dart';
import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/account/account_type_provider.dart';
import 'package:sansom/provider/category/category_provider.dart';
import 'package:sansom/provider/transaction/transaction_provider.dart';
import 'package:sansom/service/token/token_storage.dart';

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

  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      prefixStyle: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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
    final accountProvider = context.watch<AccountProvider>();
    final accountTypes = context.watch<AccountTypeProvider>().accountTypes;
    final categoryProvider = context.watch<CategoryProvider>();
    final transactionProvider = context.watch<TransactionProvider>();

    final accountIds = accountProvider.accountModel
        .map((account) => account.id)
        .toSet();

    final availableCategories = categoryProvider.categories
        .where(
          (category) =>
              selectedType == null ||
              category.type.trim().toLowerCase() == selectedType,
        )
        .toList();

    final categoryIds = availableCategories
        .map((category) => category.id)
        .toSet();

    return Container(
      color: AppColors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Header
            const Text(
              'New Transaction',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),

            // =========================
            // TYPE
            // =========================
            DropdownButtonFormField<String>(
              value: selectedType,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: _buildInputDecoration(labelText: 'Transaction Type'),
              items: const [
                DropdownMenuItem(value: 'income', child: Text('Income')),
                DropdownMenuItem(value: 'expense', child: Text('Expense')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                  if (value != null &&
                      selectedCategoryId != null &&
                      !categoryProvider.categories.any(
                        (category) =>
                            category.id == selectedCategoryId &&
                            category.type.trim().toLowerCase() == value,
                      )) {
                    selectedCategoryId = null;
                  }
                });
              },
            ),

            const SizedBox(height: 14),

            // =========================
            // ACCOUNT
            // =========================
            DropdownButtonFormField<int>(
              value: accountIds.contains(selectedAccountId)
                  ? selectedAccountId
                  : null,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: _buildInputDecoration(labelText: 'Account'),
              items: accountProvider.accountModel
                  .where((account) => accountIds.contains(account.id))
                  .map((account) {
                  final matchingAccountTypes = accountTypes.where(
                    (accountType) => accountType.id == account.accountTypeId,
                  );
                  final typeName = matchingAccountTypes.isNotEmpty
                      ? matchingAccountTypes.first.name
                      : 'Account';

                return DropdownMenuItem<int>(
                  value: account.id,
                  child: Text(
                    '${account.name} ($typeName)',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAccountId = value;
                });
              },
            ),

            const SizedBox(height: 14),

            // =========================
            // CATEGORY
            // =========================
            DropdownButtonFormField<int>(
              value: categoryIds.contains(selectedCategoryId)
                  ? selectedCategoryId
                  : null,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: _buildInputDecoration(labelText: 'Category'),
              items: availableCategories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(
                    category.name,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),

            const SizedBox(height: 14),

            // =========================
            // AMOUNT
            // =========================
            TextField(
              controller: amountController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _buildInputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),

            const SizedBox(height: 14),

            // =========================
            // DESCRIPTION
            // =========================
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _buildInputDecoration(labelText: 'Description'),
            ),

            const SizedBox(height: 14),

            // =========================
            // DATE
            // =========================
            TextField(
              controller: transactionDateController,
              readOnly: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _buildInputDecoration(
                labelText: 'Transaction Date',
                suffixIcon: const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
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

            const SizedBox(height: 14),

            // =========================
            // NOTES
            // =========================
            TextField(
              controller: notesController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _buildInputDecoration(labelText: 'Notes (Optional)'),
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
                    onPressed: transactionProvider.isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: transactionProvider.isLoading
                        ? null
                        : submitTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: transactionProvider.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textLight,
                            ),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

    final selectedCategory = context
        .read<CategoryProvider>()
        .categories
        .where((category) => category.id == selectedCategoryId)
        .firstOrNull;

    if (selectedCategory == null ||
        selectedCategory.type.trim().toLowerCase() != selectedType) {
      showError('Please select a category that matches the transaction type');
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}