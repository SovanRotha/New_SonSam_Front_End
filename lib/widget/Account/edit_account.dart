import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    nameController = TextEditingController(
      text: widget.accountName,
    );

    balanceController = TextEditingController(
      text: widget.balance.toStringAsFixed(2),
    );

    selectedAccountTypeId = widget.accountTypeId;
    selectedCurrency = widget.currency;
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();

    super.dispose();
  }

  // ============================================================
  // UPDATE ACCOUNT
  // ============================================================

  Future<void> updateAccount() async {

    final name = nameController.text.trim();
    final balanceText = balanceController.text.trim();

    // Validate name
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account name is required',
          ),
        ),
      );

      return;
    }

    // Validate balance
    final balance = double.tryParse(balanceText);

    if (balance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid balance',
          ),
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
        const SnackBar(
          content: Text(
            'Account updated successfully',
          ),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to update account',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<AccountProvider>();
    final accountTypeProvider = context.watch<AccountTypeProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),

      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              'Edit Account',

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // ACCOUNT TYPE
            // ==================================================

            DropdownButtonFormField<int>(
              value: accountTypeProvider.accountTypes.any(
                (accountType) => accountType.id == selectedAccountTypeId,
              )
                  ? selectedAccountTypeId
                  : null,

              decoration: const InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(),
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

            // ==================================================
            // ACCOUNT NAME
            // ==================================================

            TextField(
              controller: nameController,

              enabled: !provider.isLoading,

              decoration: const InputDecoration(
                labelText: 'Account Name',
                hintText: 'Enter account name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // BALANCE
            // ==================================================

            TextField(
              controller: balanceController,

              enabled: !provider.isLoading,

              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: const InputDecoration(
                labelText: 'Balance',
                hintText: 'Enter balance',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // CURRENCY
            // ==================================================

            DropdownButtonFormField<String>(
              value: selectedCurrency,

              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),

              items: const [
                DropdownMenuItem(
                  value: 'USD',
                  child: Text('USD'),
                ),

                // DropdownMenuItem(
                //   value: 'KHR',
                //   child: Text('KHR'),
                // ),
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

            const SizedBox(height: 24),

            // ==================================================
            // BUTTONS
            // ==================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,

              children: [

                // CANCEL
                TextButton(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },

                  child: const Text(
                    'Cancel',
                  ),
                ),

                const SizedBox(width: 8),

                // UPDATE
                ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : updateAccount,

                  child: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,

                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update',
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}