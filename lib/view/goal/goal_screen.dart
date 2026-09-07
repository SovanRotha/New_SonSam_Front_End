import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/goal/goal_provider.dart';
import 'package:sansom/widget/contribution/contribution_screen.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {

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
      ),
      body: ListView.builder(
          itemCount: goalProvider.goals.length,
          itemBuilder: (context, index) {
            final goal = goalProvider.goals[index];
            return ListTile(
              title: Text(goal.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${goal.description}'),
                  Text('Target Date: ${goal.targetDate}'),
                  Text('Status: ${goal.status}'),
                  if (goal.contribution != null) ...[
                    Text('Contribution Amount: ${goal.contribution!.amount}'),
                    if (goal.contribution!.note != null)
                      Text('Contribution Note: ${goal.contribution!.note}'),
                    if (goal.contribution!.contributionDate != null)
                      Text('Contribution Date: ${goal.contribution!.contributionDate}'),
                  ],
                  
                  SizedBox(height: 20.0),

                  ContributionScreen(),
                ],
              ),
            );
          }
      ),
    );
  }
}