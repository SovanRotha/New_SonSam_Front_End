import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/account/account_type_provider.dart';

class CreateAccount extends StatefulWidget {
  CreateAccount({super.key});
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  int? selectedAccountId;

  @override
  void dispose() {
    widget.accountNameController.dispose();
    widget.balanceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // You can call any method from your provider here if needed
      context.read<AccountProvider>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final accountTypeProvider = context.watch<AccountTypeProvider>();
    final accountNameController = widget.accountNameController;
    final balanceController = widget.balanceController;
    final accountIds = accountProvider.accountModel
        .map((account) => account.id)
        .toSet();

    return AlertDialog(
      title: const Text('Create Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Account Type'),
            value: accountIds.contains(selectedAccountId)
                ? selectedAccountId
                : null,

            items: accountTypeProvider.accountTypes
                .where((account) => accountIds.contains(account.id))
                .map((account) {
                  return DropdownMenuItem<int>(
                    value: account.id,
                    child: Text(account.name),
                  );
                })
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedAccountId = value;
              });
            },
          ),

          TextField(
            controller: accountNameController,
            decoration: const InputDecoration(labelText: 'Account Name'),
          ),
          TextField(
            controller: balanceController,
            decoration: const InputDecoration(labelText: 'Balance'),
            keyboardType: TextInputType.number,
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Currency'),
            items: const [DropdownMenuItem(value: 'USD', child: Text('USD'))],
            onChanged: (value) {
              // Handle currency selection
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final accountName = accountNameController.text.trim();
            final balance =
                double.tryParse(balanceController.text.trim()) ?? 0.0;
            final accountTypeId = selectedAccountId;
            final currency = 'USD'; // Replace with actual selected currency

            if (accountTypeId == null || accountName.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all required fields'),
                ),
              );
              return;
            }

            final accountProvider = context.read<AccountProvider>();
            final success = await accountProvider.createAccount({
              'name': accountName,
              'balance': balance,
              'account_type_id': accountTypeId,
              'currency': currency,
            });

            if (!mounted) return;

            if (success) {
              await accountProvider.getAccounts();
              if (!mounted) return;
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    accountProvider.errorMessage ?? 'Failed to create account',
                  ),
                ),
              );
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
