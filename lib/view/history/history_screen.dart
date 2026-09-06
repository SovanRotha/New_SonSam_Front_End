import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/transaction/transaction_provider.dart';
import 'package:sansom/service/token/token_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<TransactionProvider>().loadTransactions(TokenStorage.getToken() ?? '');
    // });
    // Replace with actual token
  }

  @override
  Widget build(BuildContext context) {
    final TransactionProvider transactionProvider =context.watch<TransactionProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: ListView.builder(
        itemCount: transactionProvider.transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactionProvider.transactions[index];
          return ListTile(
            title: Text(transaction.amount.toString()),
            subtitle: Text('\$${transaction.amount.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}