import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/account/account_type_provider.dart';
import 'package:sansom/widget/Account/create_account_type.dart';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AccountTypeProvider>().getAccountTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountTypeProvider = context.watch<AccountTypeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Type Screen'),
        actions : [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CreateAccountType();
                },
              );
            },
          ),
        ],
        ),
      body: accountTypeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : accountTypeProvider.errorMessage != null
          ? Center(child: Text(accountTypeProvider.errorMessage!))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: accountTypeProvider.accountTypes.length,
                    itemBuilder: (context, index) {
                      final accountType =
                          accountTypeProvider.accountTypes[index];
                      return ListTile(title: Text(accountType.name));
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
