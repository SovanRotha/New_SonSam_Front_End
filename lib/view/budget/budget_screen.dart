import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';

import 'package:sansom/provider/budget/budget_provider.dart';
import 'package:sansom/view/budget/budget_detail_screen.dart';
import 'package:sansom/view/budget/edit_budget.dart';
import 'package:sansom/widget/budget/additional.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Budgets',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return CreateBudget();
                } 
              );
            },
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            tooltip: 'Add Budget',
          ),
        ],
      ),
      body: _buildBody(budgetProvider),
    );
  }

  Widget _buildBody(BudgetProvider budgetProvider) {
    // Loading
    if (budgetProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Error
    if (budgetProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                budgetProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  budgetProvider.getBudget();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Try Again', style: TextStyle(color: AppColors.textLight)),
              ),
              
            ],
          ),
        ),
      );
    }

    // No budgets
    if (budgetProvider.budgets.isEmpty) {
      return _buildEmptyState();
    }

    // Display budgets
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await budgetProvider.getBudget();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: budgetProvider.budgets.length + 1,
        itemBuilder: (context, index) {
          if (index == budgetProvider.budgets.length) {
            return _buildAdditionalFeaturesCard(context);
          }

          final budget = budgetProvider.budgets[index];
          return _buildBudgetCard(context, budget);
        },
      ),
    );
  }

 Widget _buildAdditionalFeaturesCard(BuildContext context) {
   return Container(
     margin: const EdgeInsets.only(top: 4, bottom: 16),
     decoration: BoxDecoration(
       // Use a soft primary tint to make it stand out as a special feature section
       color: AppColors.primary.withOpacity(0.05),
       borderRadius: BorderRadius.circular(16),
       border: Border.all(color: AppColors.primary.withOpacity(0.2)),
     ),
     child: Material(
       color: Colors.transparent,
       borderRadius: BorderRadius.circular(16),
       child: InkWell(
         borderRadius: BorderRadius.circular(16),
         onTap: () {
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => const Additional()),
           );
         },
         child: Padding(
           padding: const EdgeInsets.all(16),
           child: Row(
             children: [
               // Leading Icon with a solid primary background container
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: AppColors.primary.withOpacity(0.12),
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: const Icon(
                   Icons.receipt_long_rounded,
                   color: AppColors.primary,
                   size: 24,
                 ),
               ),
               const SizedBox(width: 14),
               // Title & Subtitle
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text(
                       'Bills & Subscriptions',
                       style: TextStyle(
                         color: AppColors.textPrimary,
                         fontWeight: FontWeight.bold,
                         fontSize: 16,
                       ),
                     ),
                     const SizedBox(height: 3),
                     const Text(
                       'Manage recurring transactions & reminders',
                       style: TextStyle(
                         color: AppColors.textSecondary,
                         fontSize: 12,
                       ),
                     ),
                   ],
                 ),
               ),
               const SizedBox(width: 8),
               // Trailing Arrow with a circular background
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: AppColors.surface,
                   shape: BoxShape.circle,
                   border: Border.all(color: AppColors.border),
                 ),
                 child: const Icon(
                   Icons.arrow_forward_ios_rounded,
                   size: 12,
                   color: AppColors.primary,
                 ),
               ),
             ],
           ),
         ),
       ),
     ),
   );
 }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 60,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Budgets Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a budget to start managing your spending.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const CreateBudget(),
                );
              },
              icon: const Icon(Icons.add, color: AppColors.textLight),
              label: const Text('Create Budget', style: TextStyle(color: AppColors.textLight)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, dynamic budget) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BudgetDetailScreen(budget: budget),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${budget.month}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final updated = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return EditBudget(
                                budgetId: budget.id,
                                name: budget.name,
                                month: budget.month.toString(),
                                totalLimit: budget.totalLimit,
                                rollover: budget.rollover,
                                rolloverAmount: budget.rolloverAmount,
                                status: budget.status,
                              );
                            },
                          );

                          if (!context.mounted) return;

                          if (updated == true) {
                            await context.read<BudgetProvider>().getBudget();
                          }
                        }

                        if (value == 'delete') {
                          _showDeleteDialog(context, budget.id);
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
                                Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                SizedBox(width: 10),
                                Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AppColors.border, height: 1),
                ),

                // Total Limit
                const Text(
                  'Total Budget',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${budget.totalLimit}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                // Rollover information
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.sync,
                        title: 'Rollover',
                        value: '${budget.rollover}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.savings_outlined,
                        title: 'Rollover Amount',
                        value: '\$${budget.rolloverAmount}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Status & Details footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(budget.status),
                    Row(
                      children: const [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppColors.primary,
                        ),

                        
                      ],
                    ),
                  ],
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isActive = status.toLowerCase() == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green.shade700 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int budgetId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete Budget?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Are you sure you want to delete this budget? This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await context.read<BudgetProvider>().deleteBudget(budgetId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}