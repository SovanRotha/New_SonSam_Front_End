
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/goal/goal_provider.dart';
import 'package:sansom/widget/contribution/contribution_screen.dart';
import 'package:sansom/widget/contribution/create_goal.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<GoalProvider>().getGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.watch<GoalProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Screen'),

        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const CreateGoal();
                },
              );
            },
          ),
        ],
      ),

      body: goalProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : goalProvider.errorMessage != null
              ? Center(
                  child: Text(
                    goalProvider.errorMessage!,
                  ),
                )
              : goalProvider.goals.isEmpty
                  ? const Center(
                      child: Text(
                        'No saving goals found',
                      ),
                    )
                  : ListView.builder(
                      itemCount: goalProvider.goals.length,

                      itemBuilder: (context, index) {
                        final goal =
                            goalProvider.goals[index];

                        return Card(
                          margin:
                              const EdgeInsets.all(10),

                          child: ListTile(
                            title: Text(
                              goal.name,
                            ),

                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                const SizedBox(
                                  height: 8,
                                ),

                                Text(
                                  'Target Amount: '
                                  '${goal.targetAmount}',
                                ),

                                Text(
                                  'Current Amount: '
                                  '${goal.currentAmount}',
                                ),

                                if (goal.description !=
                                    null)
                                  Text(
                                    'Description: '
                                    '${goal.description}',
                                  ),

                                Text(
                                  'Target Date: '
                                  '${goal.targetDate}',
                                ),

                                Text(
                                  'Status: '
                                  '${goal.status}',
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                // Show latest contribution
                                if (goal.contribution !=
                                    null) ...[
                                  Text(
                                    'Contribution Amount: '
                                    '${goal.contribution!.amount}',
                                  ),

                                  if (goal
                                          .contribution!
                                          .note !=
                                      null)
                                    Text(
                                      'Contribution Note: '
                                      '${goal.contribution!.note}',
                                    ),

                                  if (goal
                                          .contribution!
                                          .contributionDate !=
                                      null)
                                    Text(
                                      'Contribution Date: '
                                      '${goal.contribution!.contributionDate}',
                                    ),
                                ],

                                const SizedBox(
                                  height: 12,
                                ),

                                SizedBox(
                                  width:
                                      double.infinity,

                                  child:
                                      ElevatedButton(
                                    onPressed: () async {
                                      // Open ContributionScreen
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  ContributionScreen(
                                            goalId:
                                                goal.id,
                                            goalName:
                                                goal.name,
                                          ),
                                        ),
                                      );

                                      // Make sure this screen
                                      // is still mounted
                                      if (!mounted) return;

                                      // Get the latest goal
                                      // from Laravel
                                      await context
                                          .read<
                                              GoalProvider>()
                                          .refreshGoal(
                                            goal.id,
                                          );
                                    },

                                    child:
                                        const Text(
                                      'View Contributions',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

