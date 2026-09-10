
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sansom/provider/account/account_type_provider.dart';
import 'package:sansom/widget/Account/create_account_type.dart';
import 'package:sansom/widget/Account/edit_account_type.dart';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AccountTypeProvider>().getAccountTypes();
    });
  }

  Future<void> deleteAccountType(
    BuildContext context,
    int id,
    String name,
  ) async {
    final provider = context.read<AccountTypeProvider>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account Type'),

          content: Text(
            'Are you sure you want to delete "$name"?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final success = await provider.deleteAccountType(id);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account type deleted successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to delete account type',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountTypeProvider =
        context.watch<AccountTypeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Type Screen'),

        actions: [
          IconButton(
            icon: const Icon(Icons.add),

            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const CreateAccountType();
                },
              );
            },
          ),
        ],
      ),

      body: accountTypeProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : accountTypeProvider.errorMessage != null
          ? Center(
              child: Text(
                accountTypeProvider.errorMessage!,
              ),
            )
          : accountTypeProvider.accountTypes.isEmpty
          ? const Center(
              child: Text('No account types found'),
            )
          : ListView.builder(
              itemCount:
                  accountTypeProvider.accountTypes.length,

              itemBuilder: (context, index) {
                final accountType =
                    accountTypeProvider.accountTypes[index];

                return ListTile(
                  leading: const Icon(
                    Icons.account_balance,
                  ),

                  title: Text(accountType.name),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      // EDIT
                      IconButton(
                        icon: const Icon(Icons.edit),

                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return EditAccountType(
                                accountTypeId: accountType.id,
                                accountTypeName: accountType.name,
                              );
                            },
                          );
                        },
                      ),

                      // DELETE
                      IconButton(
                        icon: const Icon(Icons.delete),

                        onPressed: () {
                          deleteAccountType(
                            context,
                            accountType.id,
                            accountType.name,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

