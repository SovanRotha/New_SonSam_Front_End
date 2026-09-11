import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
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
                        child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Create Bill',
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
                    decoration: _inputDecoration(labelText: 'Bill Name', prefixIcon: Icons.edit_note_rounded),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter bill name' : null,
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

                  // Due Date Field
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: selectedDueDate == null ? '' : formatDate(selectedDueDate!),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: _inputDecoration(
                      labelText: 'Due Date',
                      prefixIcon: Icons.calendar_month_outlined,
                      hintText: 'Select due date',
                      suffixIcon: IconButton(
                        onPressed: selectDueDate,
                        icon: const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                      ),
                    ),
                    onTap: selectDueDate,
                    validator: (value) => selectedDueDate == null ? 'Please select due date' : null,
                  ),

                  const SizedBox(height: 16),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    dropdownColor: AppColors.surface,
                    decoration: _inputDecoration(labelText: 'Status', prefixIcon: Icons.info_outline_rounded),
                    items: const [
                      DropdownMenuItem(value: 'upcoming', child: Text('Upcoming', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                      DropdownMenuItem(value: 'paid', child: Text('Paid', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                      DropdownMenuItem(value: 'overdue', child: Text('Overdue', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => selectedStatus = value);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Notes Field
                  TextFormField(
                    controller: notesController,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: _inputDecoration(labelText: 'Notes', prefixIcon: Icons.notes_rounded, hintText: 'Optional notes'),
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
                          onPressed: createBill,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Create Bill',
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

  void createBill() {
    if (!formKey.currentState!.validate()) return;

    final data = {
      'account_id': selectedAccountId,
      'category_id': selectedCategoryId,
      'name': nameController.text.trim(),
      'amount': double.parse(amountController.text),
      'due_date': formatDate(selectedDueDate!),
      'status': selectedStatus,
      'notes': notesController.text.trim().isEmpty ? null : notesController.text.trim(),
    };

    Navigator.of(context).pop(data);
  }
}