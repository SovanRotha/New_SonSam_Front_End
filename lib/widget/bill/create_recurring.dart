import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/category/category_provider.dart';
import 'package:sansom/core/constant/app_color.dart';
// Make sure to import your AppColors file here:
// import 'path/to/app_colors.dart';

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textLight,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
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
      initialDate: selectedEndDate ?? selectedStartDate ?? DateTime.now(),
      firstDate: selectedStartDate ?? DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textLight,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
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
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.repeat_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Recurring Transaction',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                
                // TYPE SELECTOR (Segmented / Custom Toggle style)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedType = 'expense'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedType == 'expense'
                                  ? AppColors.expense
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                color: selectedType == 'expense'
                                    ? AppColors.textLight
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedType = 'income'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedType == 'income'
                                  ? AppColors.income
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Income',
                              style: TextStyle(
                                color: selectedType == 'income'
                                    ? AppColors.textLight
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // AMOUNT
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icons.attach_money_rounded,
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

                // ACCOUNT
                DropdownButtonFormField<int>(
                  value: selectedAccountId,
                  dropdownColor: AppColors.surface,
                  decoration: _buildInputDecoration(
                    labelText: 'Account',
                    prefixIcon: Icons.account_balance_wallet_rounded,
                  ),
                  items: accountProvider.accountModel.map((account) {
                    return DropdownMenuItem<int>(
                      value: account.id,
                      child: Text(
                        '${account.name} (${account.accountType!.name})',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedAccountId = value),
                  validator: (value) => value == null ? 'Please select an account' : null,
                ),

                const SizedBox(height: 16),

                // CATEGORY
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  dropdownColor: AppColors.surface,
                  decoration: _buildInputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icons.category_rounded,
                  ),
                  items: categoryProvider.categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(
                        category.name,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedCategoryId = value),
                  validator: (value) => value == null ? 'Please select a category' : null,
                ),

                const SizedBox(height: 16),

                // DESCRIPTION
                TextFormField(
                  controller: descriptionController,
                  decoration: _buildInputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icons.description_rounded,
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
                  dropdownColor: AppColors.surface,
                  decoration: _buildInputDecoration(
                    labelText: 'Frequency',
                    prefixIcon: Icons.repeat_rounded,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => selectedFrequency = value);
                  },
                ),

                const SizedBox(height: 16),

                // START DATE & END DATE ROW OR STACKED
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: selectedStartDate == null ? '' : formatDate(selectedStartDate!),
                        ),
                        decoration: _buildInputDecoration(
                          labelText: 'Start Date',
                          prefixIcon: Icons.calendar_today_rounded,
                          suffixIcon: Icons.arrow_drop_down_rounded,
                        ),
                        onTap: selectStartDate,
                        validator: (value) => selectedStartDate == null ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: selectedEndDate == null ? '' : formatDate(selectedEndDate!),
                        ),
                        decoration: _buildInputDecoration(
                          labelText: 'End Date',
                          prefixIcon: Icons.event_rounded,
                          suffixIcon: Icons.arrow_drop_down_rounded,
                        ),
                        onTap: selectEndDate,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // STATUS & AUTO CREATE CARD CONTAINER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text(
                          'Auto Create',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: const Text(
                          'Automatically process transaction',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        value: autoCreate,
                        activeColor: AppColors.primary,
                        onChanged: (value) => setState(() => autoCreate = value),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // STATUS DROPDOWN
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  dropdownColor: AppColors.surface,
                  decoration: _buildInputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icons.info_outline_rounded,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'paused', child: Text('Paused')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => selectedStatus = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: createRecurring,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textLight,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Create',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.textSecondary) : null,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
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
      'end_date': selectedEndDate == null ? null : formatDate(selectedEndDate!),
      'auto_create': autoCreate,
      'status': selectedStatus,
    };

    Navigator.of(context).pop(data);
  }
}