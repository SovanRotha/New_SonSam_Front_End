
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sansom/provider/account/account_type_provider.dart';

class EditAccountType extends StatefulWidget {
  final int accountTypeId;
  final String accountTypeName;

  const EditAccountType({
    super.key,
    required this.accountTypeId,
    required this.accountTypeName,
  });

  @override
  State<EditAccountType> createState() => _EditAccountTypeState();
}

class _EditAccountTypeState extends State<EditAccountType> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.accountTypeName,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> updateAccountType() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter account type name'),
        ),
      );
      return;
    }

    final provider = context.read<AccountTypeProvider>();

    final success = await provider.updateAccountType(
      widget.accountTypeId,
      {
        'name': name,
      },
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account type updated successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to update account type',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountTypeProvider>();

    return AlertDialog(
      title: const Text('Edit Account Type'),

      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: 'Account Type Name',
          border: OutlineInputBorder(),
        ),
      ),

      actions: [
        TextButton(
          onPressed: provider.isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : updateAccountType,
          child: provider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
