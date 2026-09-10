import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/contribution/contribution_provider.dart';
import 'package:sansom/widget/contribution/create_contribution.dart';
import 'package:sansom/widget/contribution/edit_contribution.dart';

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
        .where(
          (contribution) => contribution.goalId == widget.goalId,
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contributions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.goalName,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
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
              tooltip: 'Add Contribution',
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

                if (!mounted) return;

                await context.read<ContributionProvider>().getContributions();
              },
            ),
          ),
        ],
      ),
      body: _buildBody(
        contributionProvider,
        goalContributions,
      ),
    );
  }

  Widget _buildBody(
    ContributionProvider contributionProvider,
    List goalContributions,
  ) {
    // Loading
    if (contributionProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Error
    if (contributionProvider.errorMessage != null) {
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
                contributionProvider.errorMessage!,
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
                  contributionProvider.getContributions();
                },
                child: const Text('Try Again', style: TextStyle(color: AppColors.textLight)),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (goalContributions.isEmpty) {
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
              child: const Icon(Icons.account_balance_wallet_outlined, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No contributions found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Start adding savings entries to build towards this goal.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Contributions List
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goalContributions.length,
      itemBuilder: (context, index) {
        final contribution = goalContributions[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.savings_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '+\$${contribution.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          // Edit / Delete Popup Menu
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 18),
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDialog(context, contribution);
                              }
                              if (value == 'delete') {
                                _showDeleteDialog(context, contribution.id);
                              }
                            },
                            itemBuilder: (context) {
                              return const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
                                      SizedBox(width: 10),
                                      Text('Edit', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${contribution.contributionDate}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (contribution.note != null && contribution.note!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Note: ${contribution.note}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================
  // EDIT CONTRIBUTION
  // =========================

  void _showEditDialog(
    BuildContext context,
    dynamic contribution,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return EditContribution(
          contributionId: contribution.id,
          amount: contribution.amount,
          note: contribution.note,
          contributionDate: contribution.contributionDate.toString(),
        );
      },
    );

    if (!mounted) return;

    await context.read<ContributionProvider>().getContributions();
  }

  // =========================
  // DELETE CONTRIBUTION
  // =========================

  void _showDeleteDialog(
    BuildContext context,
    int contributionId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete Contribution?',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
          content: const Text(
            'Are you sure you want to delete this contribution? This action cannot be undone.',
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

                final success = await context
                    .read<ContributionProvider>()
                    .deleteContribution(contributionId);

                if (!context.mounted) return;

                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete contribution.')),
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