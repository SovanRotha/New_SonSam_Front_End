import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
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
      if (!mounted) return;
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

  Future<void> selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedStartDate = picked;
        if (selectedEndDate != null && selectedEndDate!.isBefore(picked)) {
          selectedEndDate = null; // Reset end date if it falls before new start date
        }
      });
    }
  }

  Future<void> selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? selectedStartDate ?? DateTime.now(),
      firstDate: selectedStartDate ?? DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedEndDate = picked;
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

    final accountIds = accountProvider.accountModel.map((account) => account.id).toSet();
    final categoryIds = categoryProvider.categories.map((category) => category.id).toSet();

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.subscriptions_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Create Subscription',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Account Dropdown
                  DropdownButtonFormField<int>(
                    value: accountIds.contains(selectedAccountId) ? selectedAccountId : null,
                    dropdownColor: AppColors.surface,
                    decoration: _inputDecoration(labelText: 'Account', prefixIcon: Icons.account_balance_wallet_outlined),
                    items: accountProvider.accountModel.map((account) {
                      return DropdownMenuItem<int>(
                        value: account.id,
                        child: Text(
                          '${account.name} (${account.accountType!.name})',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedAccountId = value),
                    validator: (value) => value == null ? 'Please select an account' : null,
                  ),

                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<int>(
                    value: categoryIds.contains(selectedCategoryId) ? selectedCategoryId : null,
                    dropdownColor: AppColors.surface,
                    decoration: _inputDecoration(labelText: 'Category', prefixIcon: Icons.category_outlined),
                    items: categoryProvider.categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(
                          category.name,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedCategoryId = value),
                    validator: (value) => value == null ? 'Please select a category' : null,
                  ),

                  const SizedBox(height: 16),

                  // Name Field
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: _inputDecoration(labelText: 'Subscription Name', prefixIcon: Icons.edit_note_rounded),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter subscription name' : null,
                  ),

                  const SizedBox(height: 16),

                  // Amount Field
                  TextFormField(
                    controller: amountController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration(labelText: 'Amount', prefixIcon: Icons.attach_money_rounded),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter amount';
                      final amount = double.tryParse(value);
                      if (amount == null) return 'Please enter a valid amount';
                      if (amount <= 0) return 'Amount must be greater than 0';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Billing Cycle Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedBillingCycle,
                    dropdownColor: AppColors.surface,
                    decoration: _inputDecoration(labelText: 'Billing Cycle', prefixIcon: Icons.repeat_rounded),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => selectedBillingCycle = value);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Start Date Field
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: selectedStartDate == null ? '' : formatDate(selectedStartDate!),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: _inputDecoration(
                      labelText: 'Start Date',
                      prefixIcon: Icons.calendar_month_outlined,
                      hintText: 'Select start date',
                      suffixIcon: IconButton(
                        onPressed: selectStartDate,
                        icon: const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                      ),
                    ),
                    onTap: selectStartDate,
                    validator: (value) => selectedStartDate == null ? 'Please select start date' : null,
                  ),

                  const SizedBox(height: 16),

                  // End Date Field
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: selectedEndDate == null ? '' : formatDate(selectedEndDate!),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: _inputDecoration(
                      labelText: 'End Date (Optional)',
                      prefixIcon: Icons.event_outlined,
                      hintText: 'Select end date',
                      suffixIcon: IconButton(
                        onPressed: selectEndDate,
                        icon: const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                      ),
                    ),
                    onTap: selectEndDate,
                  ),

                  const SizedBox(height: 16),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    dropdownColor: AppColors.surface,
                    decoration: _inputDecoration(labelText: 'Status', prefixIcon: Icons.info_outline_rounded),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => selectedStatus = value);
                    },
                  ),

                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: createSubscription,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Create',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: AppColors.primary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.background.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  void createSubscription() {
    if (!formKey.currentState!.validate()) return;

    final data = {
      'account_id': selectedAccountId,
      'category_id': selectedCategoryId,
      'name': nameController.text.trim(),
      'amount': double.parse(amountController.text),
      'billing_cycle': selectedBillingCycle,
      'start_date': formatDate(selectedStartDate!),
      'end_date': selectedEndDate == null ? null : formatDate(selectedEndDate!),
      'status': selectedStatus,
    };

    Navigator.of(context).pop(data);
  }
}