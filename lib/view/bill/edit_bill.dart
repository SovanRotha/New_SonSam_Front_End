
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/bill/bill_provider.dart';
import 'package:sansom/provider/category/category_provider.dart';

class EditBill extends StatefulWidget {
  final int billId;
  final String name;
  final double amount;
  final int accountId;
  final int? categoryId;
  final String dueDate;
  final String status;
  final String? notes;

  const EditBill({
    super.key,
    required this.billId,
    required this.name,
    required this.amount,
    required this.accountId,
    this.categoryId,
    required this.dueDate,
    required this.status,
    this.notes,
  });

  @override
  State<EditBill> createState() => _EditBillState();
}

class _EditBillState extends State<EditBill> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController dueDateController;
  late TextEditingController notesController;

  int? selectedAccountId;
  int? selectedCategoryId;
  late String selectedStatus;

  final List<String> statuses = [
    'upcoming',
    'pending',
    'paid',
    'overdue',
  ];

  @override
  void initState() {
    super.initState();

    selectedAccountId = widget.accountId;
    selectedCategoryId = widget.categoryId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AccountProvider>().getAccounts();
      context.read<CategoryProvider>().getCategory();
    });

    nameController = TextEditingController(
      text: widget.name,
    );

    amountController = TextEditingController(
      text: widget.amount.toString(),
    );

    dueDateController = TextEditingController(
      text: widget.dueDate,
    );

    notesController = TextEditingController(
      text: widget.notes ?? '',
    );

    selectedStatus = widget.status;
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    dueDateController.dispose();
    notesController.dispose();

    super.dispose();
  }

  Future<void> updateBill() async {
    final name = nameController.text.trim();
    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter bill name'),
        ),
      );
      return;
    }

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
        ),
      );
      return;
    }

    if (selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an account'),
        ),
      );
      return;
    }

    final data = {
      'name': name,
      'amount': amount,
      'account_id': selectedAccountId,
      'category_id': selectedCategoryId,
      'due_date': dueDateController.text.trim(),
      'status': selectedStatus,
      'notes': notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
    };

    final provider = context.read<BillProvider>();

    final success = await provider.updateBill(
      widget.billId,
      data,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill updated successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to update bill',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();
    final accountProvider = context.watch<AccountProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return AlertDialog(
      title: const Text('Edit Bill'),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Bill Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              value: accountProvider.accountModel.any(
                (account) => account.id == selectedAccountId,
              )
                  ? selectedAccountId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Account',
                border: OutlineInputBorder(),
              ),
              items: accountProvider.accountModel.map((account) {
                return DropdownMenuItem<int>(
                  value: account.id,
                  child: Text(account.name),
                );
              }).toList(),
              onChanged: provider.isLoading
                  ? null
                  : (value) {
                      setState(() {
                        selectedAccountId = value;
                      });
                    },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<int?>(
              value: categoryProvider.categories.any(
                (category) => category.id == selectedCategoryId,
              )
                  ? selectedCategoryId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('No category'),
                ),
                ...categoryProvider.categories.map((category) {
                  return DropdownMenuItem<int?>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }),
              ],
              onChanged: provider.isLoading
                  ? null
                  : (value) {
                      setState(() {
                        selectedCategoryId = value;
                      });
                    },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: dueDateController,
              decoration: const InputDecoration(
                labelText: 'Due Date',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedStatus = value;
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: provider.isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : updateBill,
          child: provider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
