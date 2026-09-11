import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/account/account_type_provider.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  int? selectedAccountId;
  String selectedCurrency = 'USD';

  @override
  void dispose() {
    accountNameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AccountTypeProvider>().getAccountTypes();
    });
  }

  Future<void> _createAccount() async {
    final accountName = accountNameController.text.trim();
    final balance = double.tryParse(balanceController.text.trim()) ?? 0.0;
    final accountTypeId = selectedAccountId;

    if (accountTypeId == null || accountName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final accountProvider = context.read<AccountProvider>();
    final success = await accountProvider.createAccount({
      'name': accountName,
      'balance': balance,
      'account_type_id': accountTypeId,
      'currency': selectedCurrency,
    });

    if (!mounted) return;

    if (success) {
      await accountProvider.getAccounts();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accountProvider.errorMessage ?? 'Failed to create account',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountTypeProvider = context.watch<AccountTypeProvider>();
    final accountProvider = context.watch<AccountProvider>();

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
                            'Create Account',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Add a new financial account.',
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
                        (accountType) => accountType.id == selectedAccountId,
                      )
                      ? selectedAccountId
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
                  onChanged: accountProvider.isLoading
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            selectedAccountId = value;
                          });
                        },
                ),
                const SizedBox(height: 16),

                // Account Name TextField
                TextField(
                  controller: accountNameController,
                  enabled: !accountProvider.isLoading,
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
                  enabled: !accountProvider.isLoading,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration(
                    labelText: 'Balance',
                    hintText: 'Enter initial balance',
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
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                  ],
                  onChanged: accountProvider.isLoading
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
                        onPressed: accountProvider.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
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
                        onPressed: accountProvider.isLoading ? null : _createAccount,
                        child: accountProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Create',
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

  // Reusable input decoration helper with background fill removed
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
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border.withOpacity(0.8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border.withOpacity(0.8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}