import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/bill/recurring_transaction_provider.dart';
import 'package:sansom/widget/bill/create_recurring.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecurringTransactionProvider>().getRecurring();
    });
  }

  Future<void> createRecurring() async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const CreateRecurring(),
    );

    if (!mounted || data == null) return;

    final recurringProvider = context.read<RecurringTransactionProvider>();
    final created = await recurringProvider.createRecurringTransaction(data);

    if (!mounted) return;

    if (created) {
      await recurringProvider.getRecurring();
    } else if (recurringProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(recurringProvider.errorMessage!)),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final recurring = context.watch<RecurringTransactionProvider>();
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
      body: ListView.builder(
        itemCount: recurring.recurringTransactions.length,
        itemBuilder: (context, index) {
          final transaction = recurring.recurringTransactions[index];
          return ListTile(
            title: Text(transaction.description ?? 'No Description'),
            subtitle: Text('\$${transaction.amount.toStringAsFixed(2)}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Handle edit action
               final billProvider = context.read<RecurringTransactionProvider>(); 
                            context.read<RecurringTransactionProvider>().deleteRecurringTransaction(transaction.id!).then((_) {
                              // Refresh the list of bills after deletion
                              billProvider.getRecurring();
                            });
              },
              child: const Icon(Icons.delete),
            ),
          );
        },  
      ),
    );
  }
}