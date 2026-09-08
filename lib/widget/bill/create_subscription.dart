import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/category/category_provider.dart';

class CreateSubscription extends StatefulWidget {
  const CreateSubscription({super.key});

  @override
  State<CreateSubscription> createState() => _CreateSubscriptionState();
}

class _CreateSubscriptionState extends State<CreateSubscription> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final amountController = TextEditingController();

  int? selectedAccountId;
  int? selectedCategoryId;

  String selectedBillingCycle = 'monthly';
  String selectedStatus = 'active';

  DateTime? selectedNextPaymentDate;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

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
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> selectNextPaymentDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedNextPaymentDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedNextPaymentDate = date;
      });
    }
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
      initialDate:
          selectedEndDate ?? selectedStartDate ?? DateTime.now(),
      firstDate: selectedStartDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedEndDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return AlertDialog(
      title: const Text('Create Subscription'),

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

              // NAME
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Subscription Name',
                  prefixIcon: Icon(Icons.subscriptions),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subscription name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // AMOUNT
              TextFormField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(
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

              // BILLING CYCLE
              DropdownButtonFormField<String>(
                value: selectedBillingCycle,
                decoration: const InputDecoration(
                  labelText: 'Billing Cycle',
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
                      selectedBillingCycle = value;
                    });
                  }
                },
              ),

              // const SizedBox(height: 16),

              // // NEXT PAYMENT DATE
              // TextFormField(
              //   readOnly: true,
              //   controller: TextEditingController(
              //     text: selectedNextPaymentDate == null
              //         ? ''
              //         : formatDate(selectedNextPaymentDate!),
              //   ),
              //   decoration: const InputDecoration(
              //     labelText: 'Next Payment Date',
              //     prefixIcon: Icon(Icons.payment),
              //     suffixIcon: Icon(Icons.calendar_today),
              //   ),
              //   onTap: selectNextPaymentDate,
              //   validator: (value) {
              //     if (selectedNextPaymentDate == null) {
              //       return 'Please select next payment date';
              //     }
              //     return null;
              //   },
              // ),

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
                  prefixIcon: Icon(Icons.calendar_month),
                  suffixIcon: Icon(Icons.calendar_today),
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
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: selectEndDate,
              ),

              const SizedBox(height: 16),

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
                    value: 'inactive',
                    child: Text('InActive'),
                  ),
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
            createSubscription();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  void createSubscription() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final data = {
      'account_id': selectedAccountId,
      'category_id': selectedCategoryId,
      'name': nameController.text.trim(),
      'amount': double.parse(amountController.text),
      'billing_cycle': selectedBillingCycle,
      'next_payment_date': selectedNextPaymentDate == null
          ? null
          : formatDate(selectedNextPaymentDate!),
      'start_date': formatDate(
        selectedStartDate!,
      ),
      'end_date': selectedEndDate == null
          ? null
          : formatDate(selectedEndDate!),
      'status': selectedStatus,
    };

    print(data);

    Navigator.of(context).pop(data);
  }
}