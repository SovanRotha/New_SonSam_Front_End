import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/contribution/contribution_provider.dart';
import 'package:sansom/widget/contribution/create_contribution.dart';

class ContributionScreen extends StatefulWidget {
  final int goalId;
  final String goalName;

  const ContributionScreen({
    super.key,
    required this.goalId,
    required this.goalName,
  });

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ContributionProvider>().getContributions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contributionProvider = context.watch<ContributionProvider>();

    final goalContributions = contributionProvider.contributions
        .where((contribution) => contribution.goalId == widget.goalId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contributions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return CreateContribution(
                    goalId: widget.goalId,
                    goalName: widget.goalName,
                  );
                },
              );
            },
          ),
        ],
      ),

      body: contributionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : contributionProvider.errorMessage != null
          ? Center(child: Text(contributionProvider.errorMessage!))
          : goalContributions.isEmpty
          ? const Center(child: Text('No contributions found'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: goalContributions.length,
              itemBuilder: (context, index) {
                final contribution = goalContributions[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.savings)),

                    title: Text(
                      '\$${contribution.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),

                        Text('Date: ${contribution.contributionDate}'),

                        if (contribution.note != null)
                          Text('Note: ${contribution.note}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
