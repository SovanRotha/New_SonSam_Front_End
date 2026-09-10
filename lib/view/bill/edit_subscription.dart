
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/subscription/subscription_provider.dart';
import 'package:sansom/provider/category/category_provider.dart';

class EditSubscription extends StatefulWidget {
  final int subscriptionId;
  final int accountId;
  final int categoryId;
  final String name;
  final double amount;
  final String billingCycle;
  final String? nextPaymentDate;
  final String startDate;
  final String? endDate;
  final String status;

  const EditSubscription({
    super.key,
    required this.subscriptionId,
    required this.accountId,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.billingCycle,
    this.nextPaymentDate,
    required this.startDate,
    this.endDate,
    required this.status,
  });

  @override
  State<EditSubscription> createState() => _EditSubscriptionState();
}

class _EditSubscriptionState extends State<EditSubscription> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  int? selectedAccountId;
  int? selectedCategoryId;
  late String selectedBillingCycle;
  String? selectedNextPaymentDate;
  late String selectedStartDate;
  String? selectedEndDate;
  late String selectedStatus;

  final billingCycles = const ['daily', 'weekly', 'monthly', 'yearly'];
  final statuses = const ['active', 'inactive', 'cancelled'];

  @override
  void initState() {
    super.initState();

    selectedAccountId = widget.accountId;
    selectedCategoryId = widget.categoryId;
    selectedBillingCycle = billingCycles.contains(widget.billingCycle)
      ? widget.billingCycle
      : 'monthly';
    selectedNextPaymentDate = widget.nextPaymentDate;
    selectedStartDate = widget.startDate;
    selectedEndDate = widget.endDate;
    selectedStatus = statuses.contains(widget.status)
      ? widget.status
      : 'active';

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
  }

  Future<void> selectDate({required String field}) async {
    final currentValue = field == 'next'
        ? selectedNextPaymentDate
        : field == 'start'
        ? selectedStartDate
        : selectedEndDate;
    final initialDate = DateTime.tryParse(currentValue ?? '') ??
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
      if (field == 'next') {
        selectedNextPaymentDate = value;
      } else if (field == 'start') {
        selectedStartDate = value;
      } else {
        selectedEndDate = value;
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> updateSubscription() async {
    final name = nameController.text.trim();
    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter subscription name'),
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
        const SnackBar(
          content: Text('Please select an account and start date'),
        ),
      );
      return;
    }

    final data = {
      'account_id': selectedAccountId,
      'category_id': selectedCategoryId,
      'name': name,
      'amount': amount,
      'billing_cycle': selectedBillingCycle,
      'next_payment_date': selectedNextPaymentDate,
      'start_date': selectedStartDate,
      'end_date': selectedEndDate,
      'status': selectedStatus,
    };

    final provider = context.read<SubscriptionProvider>();

    final success = await provider.updateSubscription(
      widget.subscriptionId,
      data,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Subscription updated successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to update subscription',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();
    final accountProvider = context.watch<AccountProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return AlertDialog(
      title: const Text('Edit Subscription'),

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
                : (value) => setState(() => selectedAccountId = value),
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
                : (value) => setState(() => selectedCategoryId = value),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Subscription Name',
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
            value: selectedBillingCycle,
            decoration: const InputDecoration(labelText: 'Billing Cycle'),
            items: billingCycles.map((cycle) {
              return DropdownMenuItem(value: cycle, child: Text(cycle));
            }).toList(),
            onChanged: provider.isLoading
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => selectedBillingCycle = value);
                    }
                  },
          ),

          const SizedBox(height: 12),

          TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text: selectedNextPaymentDate ?? '',
            ),
            decoration: const InputDecoration(
              labelText: 'Next Payment Date',
            ),
            onTap: () => selectDate(field: 'next'),
          ),

          const SizedBox(height: 12),

          TextFormField(
            readOnly: true,
            controller: TextEditingController(text: selectedStartDate),
            decoration: const InputDecoration(labelText: 'Start Date'),
            onTap: () => selectDate(field: 'start'),
          ),

          const SizedBox(height: 12),

          TextFormField(
            readOnly: true,
            controller: TextEditingController(text: selectedEndDate ?? ''),
            decoration: const InputDecoration(
              labelText: 'End Date (Optional)',
            ),
            onTap: () => selectDate(field: 'end'),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: const InputDecoration(labelText: 'Status'),
            items: statuses.map((status) {
              return DropdownMenuItem(value: status, child: Text(status));
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
              : updateSubscription,
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

