
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/budget/budget_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<BudgetProvider>().getBudget();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Screen'),
      ),
      body: _buildBody(budgetProvider),
    );
  }

  Widget _buildBody(BudgetProvider budgetProvider) {
    if (budgetProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (budgetProvider.errorMessage != null) {
      return Center(
        child: Text(budgetProvider.errorMessage!),
      );
    }

    if (budgetProvider.budget == null) {
      return const Center(
        child: Text('No budget found'),
      );
    }

    final budget = budgetProvider.budget!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: ${budget.name}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text('Month: ${budget.month}'),
          const SizedBox(height: 10),
          Text('Total Limit: \$${budget.totalLimit}'),
          const SizedBox(height: 10),
          Text('Rollover: ${budget.rollover}'),
          const SizedBox(height: 10),
          Text('Rollover Amount: \$${budget.rolloverAmount}'),
          const SizedBox(height: 10),
          Text('Status: ${budget.status}'),
        ],
      ),
    );
  }
}
