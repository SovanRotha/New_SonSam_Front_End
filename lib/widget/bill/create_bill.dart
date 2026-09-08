import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/category/category_provider.dart';

class CreateBill extends StatefulWidget {
  const CreateBill({super.key});

  @override
  State<CreateBill> createState() => _CreateBillState();
}

class _CreateBillState extends State<CreateBill> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  int? selectedAccountId;
  int? selectedCategoryId;

  String selectedStatus = 'upcoming';

  DateTime? selectedDueDate;

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
    nameController.dispose();
    amountController.dispose();
    notesController.dispose();

    super.dispose();
  }

  Future<void> selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDueDate = picked;
      });
    }
  }

  String formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final accountIds = accountProvider.accountModel
        .map((account) => account.id)
        .toSet();
    final categoryIds = categoryProvider.categories
        .map((category) => category.id)
        .toSet();

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Bill',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // Account
                DropdownButtonFormField<int>(
                  value: accountIds.contains(selectedAccountId)
                      ? selectedAccountId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Account',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(),
                  ),
                  items: accountProvider.accountModel.map((account) {
                    return DropdownMenuItem<int>(
                      value: account.id,
                      child: Text(
                        '${account.name} (${account.accountType!.name})',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAccountId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an account';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<int>(
                  value: categoryIds.contains(selectedCategoryId)
                      ? selectedCategoryId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: categoryProvider.categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Bill Name',
                    prefixIcon: Icon(Icons.receipt_long),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter bill name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter amount';
                    }

                    final amount = double.tryParse(value);

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

                // Due Date
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedDueDate == null
                        ? ''
                        : formatDate(selectedDueDate!),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    prefixIcon: const Icon(Icons.calendar_month),
                    border: const OutlineInputBorder(),
                    hintText: 'Select due date',
                    suffixIcon: IconButton(
                      onPressed: selectDueDate,
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  onTap: selectDueDate,
                  validator: (value) {
                    if (selectedDueDate == null) {
                      return 'Please select due date';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Status
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info_outline),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'upcoming',
                      child: Text('Upcoming'),
                    ),
                    DropdownMenuItem(value: 'paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('Cancelled'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                    hintText: 'Optional notes',
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          createBill();
                        },
                        child: const Text('Create Bill'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void createBill() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final data = {
      'account_id': selectedAccountId,
      'category_id': selectedCategoryId,
      'name': nameController.text.trim(),
      'amount': double.parse(amountController.text),
      'due_date': formatDate(selectedDueDate!),
      'status': selectedStatus,
      'notes': notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
    };

    print(data);

    Navigator.of(context).pop(data);
  }
}
