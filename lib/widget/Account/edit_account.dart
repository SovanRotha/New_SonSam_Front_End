import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/account/account_type_provider.dart';

class EditAccount extends StatefulWidget {
  final int accountId;
  final int accountTypeId;
  final String accountName;
  final double balance;
  final String currency;

  const EditAccount({
    super.key,
    required this.accountId,
    required this.accountTypeId,
    required this.accountName,
    required this.balance,
    required this.currency,
  });

  @override
  State<EditAccount> createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  late TextEditingController nameController;
  late TextEditingController balanceController;

  late int selectedAccountTypeId;
  late String selectedCurrency;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AccountTypeProvider>().getAccountTypes();
    });

    nameController = TextEditingController(text: widget.accountName);
    balanceController = TextEditingController(text: widget.balance.toStringAsFixed(2));

    selectedAccountTypeId = widget.accountTypeId;
    selectedCurrency = widget.currency;
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  Future<void> updateAccount() async {
    final name = nameController.text.trim();
    final balanceText = balanceController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account name is required'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final balance = double.tryParse(balanceText);

    if (balance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid balance'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final provider = context.read<AccountProvider>();

    final updated = await provider.updateAccount(
      widget.accountId,
      {
        'account_type_id': selectedAccountTypeId,
        'name': name,
        'balance': balance,
        'currency': selectedCurrency,
      },
    );

    if (!mounted) return;

    if (updated) {
      await provider.getAccounts();

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account updated successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to update account'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final accountTypeProvider = context.watch<AccountTypeProvider>();

    return Dialog(
      backgroundColor: AppColors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Account',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Update your account details below.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Account Type Dropdown
                DropdownButtonFormField<int>(
                  value: accountTypeProvider.accountTypes.any(
                    (accountType) => accountType.id == selectedAccountTypeId,
                  )
                      ? selectedAccountTypeId
                      : null,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: _inputDecoration(
                    labelText: 'Account Type',
                    prefixIcon: Icons.category_outlined,
                  ),
                  items: accountTypeProvider.accountTypes.map((accountType) {
                    return DropdownMenuItem<int>(
                      value: accountType.id,
                      child: Text(accountType.name),
                    );
                  }).toList(),
                  onChanged: provider.isLoading
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            selectedAccountTypeId = value;
                          });
                        },
                ),
                const SizedBox(height: 16),

                // Account Name TextField
                TextField(
                  controller: nameController,
                  enabled: !provider.isLoading,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: _inputDecoration(
                    labelText: 'Account Name',
                    hintText: 'Enter account name',
                    prefixIcon: Icons.edit_outlined,
                  ),
                ),
                const SizedBox(height: 16),

                // Balance TextField
                TextField(
                  controller: balanceController,
                  enabled: !provider.isLoading,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration(
                    labelText: 'Balance',
                    hintText: 'Enter balance',
                    prefixIcon: Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(height: 16),

                // Currency Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: _inputDecoration(
                    labelText: 'Currency',
                    prefixIcon: Icons.attach_money_rounded,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'USD',
                      child: Text('USD'),
                    ),
                  ],
                  onChanged: provider.isLoading
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            selectedCurrency = value;
                          });
                        },
                ),
                const SizedBox(height: 28),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: provider.isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.border.withOpacity(0.8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: provider.isLoading ? null : updateAccount,
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Update',
                                style: TextStyle(
                                  color: Colors.white,
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
        ),
      ),
    );
  }

  // Reusable input decoration helper to keep code DRY and clean
  InputDecoration _inputDecoration({
    required String labelText,
    String? hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
      prefixIcon: Icon(prefixIcon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border.withOpacity(0.6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border.withOpacity(0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}