import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/goal/goal_provider.dart';
import 'package:sansom/widget/contribution/contribution_screen.dart';
import 'package:sansom/widget/contribution/create_goal.dart';
import 'package:sansom/widget/contribution/edit_goal.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Savings Goals',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              tooltip: 'Add Goal',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const CreateGoal();
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: _buildBody(goalProvider),
    );
  }

  Widget _buildBody(GoalProvider goalProvider) {
    // Loading
    if (goalProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Error
    if (goalProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                goalProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  goalProvider.getGoals();
                },
                child: const Text('Try Again', style: TextStyle(color: AppColors.textLight)),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (goalProvider.goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flag_outlined, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No saving goals found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create a new goal to track your financial targets.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Goals List
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goalProvider.goals.length,
      itemBuilder: (context, index) {
        final goal = goalProvider.goals[index];

        // Calculations for progress bar
        final double target = double.tryParse('${goal.targetAmount}') ?? 1.0;
        final double current = double.tryParse('${goal.currentAmount}') ?? 0.0;
        final double progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
        final int percent = (progress * 100).toInt();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Title & Menu
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusBadge(goal.status ?? 'active'),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context, goal);
                        }
                        if (value == 'delete') {
                          _showDeleteDialog(context, goal.id);
                        }
                      },
                      itemBuilder: (context) {
                        return const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                                SizedBox(width: 10),
                                Text('Edit', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                SizedBox(width: 10),
                                Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),

                if (goal.description != null && goal.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    goal.description!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],

                const SizedBox(height: 16),

                // Amount breakdown row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Saved', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '\$${goal.currentAmount}',
                          style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Target Amount', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '\$${goal.targetAmount}',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Progress Bar Indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),

                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$percent% completed',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Target Date: ${goal.targetDate}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),

                // Latest contribution section if available
                if (goal.contribution != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: AppColors.border),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.history, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      const Text(
                        'Latest Contribution: ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$${goal.contribution!.amount}',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      if (goal.contribution!.contributionDate != null) ...[
                        const Spacer(),
                        Text(
                          '${goal.contribution!.contributionDate}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ]
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // View Contributions Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ContributionScreen(
                              goalId: goal.id,
                              goalName: goal.name,
                            );
                          },
                        ),
                      );

                      if (!mounted) return;

                      await context.read<GoalProvider>().refreshGoal(goal.id);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'View Details & Contributions',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic goal) async {
    await showDialog(
      context: context,
      builder: (context) {
        return EditGoal(
          goalId: goal.id,
          name: goal.name,
          targetAmount: goal.targetAmount,
          currentAmount: goal.currentAmount,
          description: goal.description,
          targetDate: goal.targetDate.toString(),
          status: goal.status,
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int goalId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete Goal?',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
          content: const Text(
            'Are you sure you want to delete this goal? This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final success = await context.read<GoalProvider>().deleteGoal(goalId);

                if (!context.mounted) return;

                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete goal.')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}