import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/widget/Account/create_account.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AccountProvider>().getAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CreateAccount();
                },
              );
            },
          ),
        ],
      ),
      body: accountProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : accountProvider.errorMessage != null
          ? Center(child: Text(accountProvider.errorMessage!))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: accountProvider.accountModel.length,
                    itemBuilder: (context, index) {
                      final accountType = accountProvider.accountModel[index];
                      return ListTile(
                        title: Text(accountType.name),
                        subtitle: Text(
                          'Balance: ${accountType.balance.toStringAsFixed(2)}',
                        ),
                        leading: const Icon(Icons.account_balance_wallet),
                        trailing: IconButton(
                          icon: const Icon(Icons.block),
                          tooltip: 'Deactivate account',
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Deactivate Account'),
                                content: const Text(
                                  'Are you sure you want to deactivate this account?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(true),
                                    child: const Text('Deactivate'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed != true) return;

                            final deactivated = await accountProvider
                                .deactivateAccount(accountType.id);

                            if (!mounted || deactivated) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  accountProvider.errorMessage ??
                                      'Failed to deactivate account',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
