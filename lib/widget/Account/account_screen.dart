import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sansom/models/account/account_model.dart';
import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/widget/Account/create_account.dart';
import 'package:sansom/widget/Account/edit_account.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  @override
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
        title: const Text(
          'Accounts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Account',
            onPressed: () {
              _showCreateAccountDialog(context);
            },
          ),
        ],
      ),

      body: _buildBody(accountProvider),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(AccountProvider accountProvider) {

    // Loading
    if (accountProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error
    if (accountProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),

              const SizedBox(height: 12),

              Text(
                accountProvider.errorMessage!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  accountProvider.getAccounts();
                },

                child: const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (accountProvider.accountModel.isEmpty) {
      return _buildEmptyState();
    }

    // Account list
    return RefreshIndicator(
      onRefresh: () async {
        await accountProvider.getAccounts();
      },

      child: ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: accountProvider.accountModel.length,

        itemBuilder: (context, index) {
          final account =
              accountProvider.accountModel[index];

          return _buildAccountCard(
            context,
            account,
          );
        },
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 60,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Accounts Yet',

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Create an account to start managing your money.',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                _showCreateAccountDialog(context);
              },

              icon: const Icon(
                Icons.add,
              ),

              label: const Text(
                'Create Account',
              ),

              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ACCOUNT CARD
  // ============================================================

  Widget _buildAccountCard(
    BuildContext context,
    AccountModel account,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        child: Row(
          children: [

            // ==================================================
            // ACCOUNT ICON
            // ==================================================

            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),

              child: const Icon(
                Icons.account_balance_wallet,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            // ==================================================
            // ACCOUNT INFORMATION
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    account.name,

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Balance: ${account.balance.toStringAsFixed(2)}',

                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // MORE MENU
            // ==================================================

            PopupMenuButton<String>(
              onSelected: (value) {

                // EDIT
                if (value == 'edit') {
                  _showEditAccountDialog(
                    context,
                    account.id,
                    account.accountType?.id ?? account.accountTypeId,
                    account.name,
                    account.balance,
                    account.currency,
                  );
                }

                // DEACTIVATE
                if (value == 'deactivate') {
                  _showDeactivateDialog(
                    context,
                    account.id,
                    account.name,
                  );
                }
              },

              itemBuilder: (context) {
                return const [

                  // ==========================================
                  // EDIT
                  // ==========================================

                  PopupMenuItem<String>(
                    value: 'edit',

                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: Colors.blue,
                        ),

                        SizedBox(width: 10),

                        Text(
                          'Edit',
                        ),
                      ],
                    ),
                  ),

                  // ==========================================
                  // DEACTIVATE
                  // ==========================================

                  PopupMenuItem<String>(
                    value: 'deactivate',

                    child: Row(
                      children: [
                        Icon(
                          Icons.block,
                          color: Colors.orange,
                        ),

                        SizedBox(width: 10),

                        Text(
                          'Deactivate',
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CREATE ACCOUNT DIALOG
  // ============================================================

  void _showCreateAccountDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return  Dialog(
          child: CreateAccount(),
        );
      },
    );
  }

  // ============================================================
  // EDIT ACCOUNT DIALOG
  // ============================================================

  void _showEditAccountDialog(
    BuildContext context,
    int accountId,
    int accountTypeId,
    String accountName,
    double balance,
    String currency
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return Dialog(
          child: EditAccount(
            accountId: accountId,
            accountTypeId: accountTypeId,
            accountName: accountName,
            balance: balance,
            currency: currency,
          ),
        );
      },
    );
  }

  // ============================================================
  // DEACTIVATE ACCOUNT DIALOG
  // ============================================================

  void _showDeactivateDialog(
    BuildContext context,
    int accountId,
    String accountName,
  ) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Deactivate Account?',
          ),

          content: Text(
            'Are you sure you want to deactivate "$accountName"?',
          ),

          actions: [

            // ================================================
            // CANCEL
            // ================================================

            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },

              child: const Text(
                'Cancel',
              ),
            ),

            // ================================================
            // DEACTIVATE
            // ================================================

            TextButton(
              onPressed: () async {

                Navigator.of(dialogContext).pop();

                final provider =
                    context.read<AccountProvider>();

                final deactivated =
                    await provider.deactivateAccount(
                  accountId,
                );

                if (!mounted) return;

                if (deactivated) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Account deactivated successfully',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.errorMessage ??
                            'Failed to deactivate account',
                      ),
                    ),
                  );
                }
              },

              child: const Text(
                'Deactivate',

                style: TextStyle(
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}