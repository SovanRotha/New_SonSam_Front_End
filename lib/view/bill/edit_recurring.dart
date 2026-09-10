
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/bill/recurring_transaction_provider.dart';
import 'package:sansom/provider/category/category_provider.dart';

class EditRecurring extends StatefulWidget {
  final int recurringId;
  final int accountId;
  final int? categoryId;
  final String type;
  final String? description;
  final double amount;
  final String frequency;
  final String startDate;
  final String? endDate;
  final bool autoCreate;
  final String status;

  const EditRecurring({
    super.key,
    required this.recurringId,
    required this.accountId,
    this.categoryId,
    required this.type,
    this.description,
    required this.amount,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.autoCreate,
    required this.status,
  });

  @override
  State<EditRecurring> createState() => _EditRecurringState();
}

class _EditRecurringState extends State<EditRecurring> {
  late TextEditingController descriptionController;
  late TextEditingController amountController;
  int? selectedAccountId;
  int? selectedCategoryId;
  late String selectedType;
  late String selectedFrequency;
  late String selectedStartDate;
  String? selectedEndDate;
  late bool autoCreate;
  late String selectedStatus;

  final types = const ['expense', 'income'];
  final frequencies = const ['daily', 'weekly', 'monthly', 'yearly'];
  final statuses = const ['active', 'inactive'];

  @override
  void initState() {
    super.initState();

    selectedAccountId = widget.accountId;
    selectedCategoryId = widget.categoryId;
    selectedType = types.contains(widget.type)
      ? widget.type
      : 'expense';
    selectedFrequency = frequencies.contains(widget.frequency)
      ? widget.frequency
      : 'monthly';
    selectedStartDate = widget.startDate;
    selectedEndDate = widget.endDate;
    autoCreate = widget.autoCreate;
    selectedStatus = statuses.contains(widget.status)
      ? widget.status
      : 'active';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AccountProvider>().getAccounts();
      context.read<CategoryProvider>().getCategory();
    });

    descriptionController = TextEditingController(
      text: widget.description ?? '',
    );

    amountController = TextEditingController(
      text: widget.amount.toString(),
    );
  }

  Future<void> selectDate({required bool start}) async {
    final initialDate = DateTime.tryParse(
          start ? selectedStartDate : selectedEndDate ?? selectedStartDate,
        ) ??
        DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final value = '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    setState(() {
      if (start) {
        selectedStartDate = value;
      } else {
        selectedEndDate = value;
      }
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> updateRecurring() async {
    final description = descriptionController.text.trim();
    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description'),
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

    if (selectedAccountId == null || selectedStartDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account and start date')),
      );
      return;
    }

    final data = {
      'account_id': selectedAccountId,
      'category_id': selectedCategoryId,
      'type': selectedType,
      'description': description,
      'amount': amount,
      'frequency': selectedFrequency,
      'start_date': selectedStartDate,
      'end_date': selectedEndDate,
      'auto_create': autoCreate,
      'status': selectedStatus,
    };

    final provider =
        context.read<RecurringTransactionProvider>();

    final success = await provider.updateRecurringTransaction(
      widget.recurringId,
      data,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recurring transaction updated successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to update recurring transaction',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<RecurringTransactionProvider>();
    final accountProvider = context.watch<AccountProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return AlertDialog(
      title: const Text('Edit Recurring'),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          DropdownButtonFormField<int>(
            value: accountProvider.accountModel.any(
              (account) => account.id == selectedAccountId,
            )
                ? selectedAccountId
                : null,
            decoration: const InputDecoration(labelText: 'Account'),
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

          DropdownButtonFormField<int>(
            value: categoryProvider.categories.any(
              (category) => category.id == selectedCategoryId,
            )
                ? selectedCategoryId
                : null,
            decoration: const InputDecoration(labelText: 'Category'),
            items: categoryProvider.categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
            onChanged: provider.isLoading
                ? null
                : (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: const InputDecoration(labelText: 'Type'),
            items: types.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: provider.isLoading
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
          ),

          const SizedBox(height: 12),

          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedFrequency,
            decoration: const InputDecoration(labelText: 'Frequency'),
            items: frequencies.map((frequency) {
              return DropdownMenuItem(
                value: frequency,
                child: Text(frequency),
              );
            }).toList(),
            onChanged: provider.isLoading
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => selectedFrequency = value);
                    }
                  },
          ),

          const SizedBox(height: 12),

          TextFormField(
            readOnly: true,
            controller: TextEditingController(text: selectedStartDate),
            decoration: const InputDecoration(labelText: 'Start Date'),
            onTap: () => selectDate(start: true),
          ),

          const SizedBox(height: 12),

          TextFormField(
            readOnly: true,
            controller: TextEditingController(text: selectedEndDate ?? ''),
            decoration: const InputDecoration(
              labelText: 'End Date (Optional)',
            ),
            onTap: () => selectDate(start: false),
          ),

          const SizedBox(height: 12),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto Create'),
            value: autoCreate,
            onChanged: provider.isLoading
                ? null
                : (value) {
                    setState(() => autoCreate = value);
                  },
          ),

          DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: const InputDecoration(labelText: 'Status'),
            items: statuses.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: provider.isLoading
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => selectedStatus = value);
                    }
                  },
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
              : updateRecurring,
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

