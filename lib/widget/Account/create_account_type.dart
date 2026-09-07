import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/account/account_type_provider.dart';

class CreateAccountType extends StatefulWidget {
  const CreateAccountType({super.key});

  @override
  State<CreateAccountType> createState() => _CreateAccountTypeState();
}

class _CreateAccountTypeState extends State<CreateAccountType> {
  final accountTypeController = TextEditingController();

  @override
  void dispose() {
    accountTypeController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Account Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: accountTypeController,
            decoration: const InputDecoration(labelText: 'Account Type Name'),
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
          onPressed: () {
            final accountTypeName = accountTypeController.text.trim();
            if (accountTypeName.isNotEmpty) {
              _createAccountType(accountTypeName);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid account type name'),
                ),
              );
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createAccountType(String name) async {
    final success = await context.read<AccountTypeProvider>().createAccountType(
      {'name': name},
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      final error = context.read<AccountTypeProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to create account type')),
      );
    }
  }
}
