import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/category/category_provider.dart';

class CreateRecurring extends StatefulWidget {
  const CreateRecurring({super.key});

  @override
  State<CreateRecurring> createState() => _CreateRecurringState();
}

class _CreateRecurringState extends State<CreateRecurring> {
  final formKey = GlobalKey<FormState>();

  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  int? selectedAccountId;
  int? selectedCategoryId;

  String selectedType = 'expense';
  String selectedFrequency = 'monthly';
  String selectedStatus = 'active';

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  bool autoCreate = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().getAccounts();
      context.read<CategoryProvider>().getCategory();
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();

    super.dispose();
  }

  Future<void> selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedStartDate = date;
      });
    }
  }

  Future<void> selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ??
          selectedStartDate ??
          DateTime.now(),
      firstDate: selectedStartDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedEndDate = date;
      });
    }
  }

  String formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return AlertDialog(
      title: const Text('Create Recurring Transaction'),

      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ACCOUNT
              DropdownButtonFormField<int>(
                value: selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Account',
                  prefixIcon: Icon(
                    Icons.account_balance_wallet,
                  ),
                ),
                items: accountProvider.accountModel.map((account) {
                  return DropdownMenuItem<int>(
                    value: account.id,
                    child: Text(
                      '${account.name} '
                      '(${account.accountType!.name})',
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

              // CATEGORY
              DropdownButtonFormField<int>(
                value: selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
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

              // TYPE
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  prefixIcon: Icon(Icons.swap_vert),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'expense',
                    child: Text('Expense'),
                  ),
                  DropdownMenuItem(
                    value: 'income',
                    child: Text('Income'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // AMOUNT
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }

                  if (double.tryParse(value) == null) {
                    return 'Enter a valid amount';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // DESCRIPTION
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // FREQUENCY
              DropdownButtonFormField<String>(
                value: selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'daily',
                    child: Text('Daily'),
                  ),
                  DropdownMenuItem(
                    value: 'weekly',
                    child: Text('Weekly'),
                  ),
                  DropdownMenuItem(
                    value: 'monthly',
                    child: Text('Monthly'),
                  ),
                  DropdownMenuItem(
                    value: 'yearly',
                    child: Text('Yearly'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedFrequency = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // START DATE
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: selectedStartDate == null
                      ? ''
                      : formatDate(selectedStartDate!),
                ),
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                onTap: selectStartDate,
                validator: (value) {
                  if (selectedStartDate == null) {
                    return 'Please select start date';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // END DATE
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: selectedEndDate == null
                      ? ''
                      : formatDate(selectedEndDate!),
                ),
                decoration: const InputDecoration(
                  labelText: 'End Date (Optional)',
                  prefixIcon: Icon(Icons.event),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                onTap: selectEndDate,
              ),

              const SizedBox(height: 16),

              // AUTO CREATE
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto Create'),
                subtitle: const Text(
                  'Automatically create the transaction',
                ),
                value: autoCreate,
                onChanged: (value) {
                  setState(() {
                    autoCreate = value;
                  });
                },
              ),

              const SizedBox(height: 8),

              // STATUS
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'active',
                    child: Text('Active'),
                  ),
                  DropdownMenuItem(
                    value: 'paused',
                    child: Text('Paused'),
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
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: () {
            createRecurring();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  void createRecurring() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final data = {
      'account_id': selectedAccountId,
      'category_id': selectedCategoryId,
      'type': selectedType,
      'amount': double.parse(amountController.text),
      'description': descriptionController.text.trim(),
      'frequency': selectedFrequency,
      'start_date': formatDate(selectedStartDate!),
      'end_date': selectedEndDate == null
          ? null
          : formatDate(selectedEndDate!),
      'auto_create': autoCreate,
      'status': selectedStatus,
    };

    print(data);

    Navigator.of(context).pop(data);
  }
}