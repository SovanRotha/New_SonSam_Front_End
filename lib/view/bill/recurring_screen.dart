
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sansom/provider/bill/recurring_transaction_provider.dart';
import 'package:sansom/view/bill/edit_recurring.dart';
import 'package:sansom/widget/bill/create_recurring.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<RecurringTransactionProvider>()
          .getRecurring();
    });
  }

  Future<void> createRecurring() async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const CreateRecurring(),
    );

    if (!mounted || data == null) return;

    final recurringProvider =
        context.read<RecurringTransactionProvider>();

    final created =
        await recurringProvider.createRecurringTransaction(data);

    if (!mounted) return;

    if (created) {
      await recurringProvider.getRecurring();
    } else if (recurringProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            recurringProvider.errorMessage!,
          ),
        ),
      );
    }
  }

  Future<void> deleteRecurring(int id) async {
    final provider =
        context.read<RecurringTransactionProvider>();

    final success =
        await provider.deleteRecurringTransaction(id);

    if (!mounted) return;

    if (success) {
      await provider.getRecurring();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recurring transaction deleted successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to delete recurring transaction',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recurring =
        context.watch<RecurringTransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring'),

        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: createRecurring,
          ),
        ],
      ),

      body: recurring.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : recurring.errorMessage != null
          ? Center(
              child: Text(
                recurring.errorMessage!,
              ),
            )
          : recurring.recurringTransactions.isEmpty
          ? const Center(
              child: Text('No recurring transactions'),
            )
          : ListView.builder(
              itemCount:
                  recurring.recurringTransactions.length,

              itemBuilder: (context, index) {
                final transaction =
                    recurring.recurringTransactions[index];

                return ListTile(
                  title: Text(
                    transaction.description ??
                        'No Description',
                  ),

                  subtitle: Text(
                    '\$${transaction.amount.toStringAsFixed(2)}',
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // EDIT
                      IconButton(
                        icon: const Icon(Icons.edit),

                        onPressed: () async {
                          final updated =
                              await showDialog<bool>(
                            context: context,
                            builder: (_) {
                              return EditRecurring(
                                recurringId:
                                    transaction.id!,
                                accountId: transaction.accountId,
                                categoryId: transaction.categoryId,
                                type: transaction.type,
                                description:
                                    transaction.description,
                                amount:
                                    transaction.amount,
                                frequency: transaction.frequency,
                                startDate: transaction.startDate,
                                endDate: transaction.endDate,
                                autoCreate: transaction.autoCreate,
                                status: transaction.status,
                              );
                            },
                          );

                          if (!mounted) return;

                          if (updated == true) {
                            await context
                                .read<
                                    RecurringTransactionProvider>()
                                .getRecurring();
                          }
                        },
                      ),

                      // DELETE
                      IconButton(
                        icon: const Icon(Icons.delete),

                        onPressed: () async {
                          final confirm =
                              await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  'Delete Recurring',
                                ),

                                content: Text(
                                  'Are you sure you want to delete '
                                  '"${transaction.description ?? 'this transaction'}"?',
                                ),

                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                        false,
                                      );
                                    },
                                    child:
                                        const Text('Cancel'),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                        true,
                                      );
                                    },
                                    child:
                                        const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm != true ||
                              !mounted) {
                            return;
                          }

                          await deleteRecurring(
                            transaction.id!,
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

