import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/budget/budget_provider.dart';
import 'package:sansom/view/budget/budget_detail_screen.dart';
import 'package:sansom/view/category/category_screen.dart';
import 'package:sansom/widget/budget/create_budget.dart';

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
        actions: [
          IconButton(
            onPressed: () {
              showDialog(context: context, builder: ((context) => CreateBudget()));
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),

      body: _buildBody(budgetProvider),
    );
  }

  Widget _buildBody(BudgetProvider budgetProvider) {
    // Loading
    if (budgetProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (budgetProvider.errorMessage != null) {
      return Center(child: Text(budgetProvider.errorMessage!));
    }

    // No budgets
    if (budgetProvider.budgets.isEmpty) {
      return const Center(child: Text('No budget found'));
    }

    // Display all budgets
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: budgetProvider.budgets.length,
      itemBuilder: (context, index) {
        final budget = budgetProvider.budgets[index];

        return Card(
  margin: const EdgeInsets.only(bottom: 16),
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BudgetDetailScreen(
            // budgetId: budget.id, =====================//

            //===================================//
          ),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            budget.name,
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

          Text(
            'Rollover Amount: \$${budget.rolloverAmount}',
          ),

          const SizedBox(height: 10),

          Text('Status: ${budget.status}'),

          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {
                context
                    .read<BudgetProvider>()
                    .deleteBudget(budget.id);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
      },
    );
  }
}
