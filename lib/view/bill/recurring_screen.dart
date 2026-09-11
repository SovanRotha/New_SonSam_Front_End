import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/bill/recurring_transaction_provider.dart';
import 'package:sansom/view/bill/edit_recurring.dart';
import 'package:sansom/widget/bill/create_recurring.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recurring transaction created successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (recurringProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(recurringProvider.errorMessage!),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recurring = context.watch<RecurringTransactionProvider>();

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              _buildBody(recurring),
              Positioned(
                right: 25,
                bottom: 40,
                child: FloatingActionButton(
                  onPressed: createRecurring,
                  tooltip: 'Add Recurring Transaction',
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: AppColors.textLight),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(RecurringTransactionProvider recurringProvider) {
    // Loading State
    if (recurringProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    // Error State
    if (recurringProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, size: 40, color: Colors.red),
              ),
              const SizedBox(height: 16),
              Text(
                recurringProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => recurringProvider.getRecurring(),
                child: const Text('Try Again', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    // Empty State
    if (recurringProvider.recurringTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.repeat_outlined,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Recurring Transactions',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up recurring income or expenses to automate your tracking.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: createRecurring,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Recurring',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // List State
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => await recurringProvider.getRecurring(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recurringProvider.recurringTransactions.length,
        itemBuilder: (context, index) {
          final transaction = recurringProvider.recurringTransactions[index];
          return _buildRecurringCard(context, transaction);
        },
      ),
    );
  }

  // ============================================================
  // RECURRING CARD
  // ============================================================

  Widget _buildRecurringCard(BuildContext context, dynamic transaction) {
    final String status = transaction.status.toString().toLowerCase();
    final bool isActive = status == 'active';
    final String type = transaction.type.toString().toLowerCase();
    final bool isIncome = type == 'income';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Description & Amount + Menu
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: (isIncome ? Colors.green : AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isIncome ? Colors.green : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description ?? 'No Description',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isIncome ? Colors.green : AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge & Popup Menu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(transaction.status, isActive),
                    PopupMenuButton<String>(
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _handleEditRecurring(context, transaction);
                        } else if (value == 'delete') {
                          _handleDeleteRecurring(context, transaction);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                              SizedBox(width: 10),
                              Text('Edit', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              SizedBox(width: 10),
                              Text('Delete', style: TextStyle(color: Colors.red, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.border),
            ),

            // Details Section
            RecurringDetail(
              label: 'Frequency',
              value: transaction.frequency ?? 'N/A',
            ),
            const SizedBox(height: 6),
            RecurringDetail(
              label: 'Start Date',
              value: transaction.startDate ?? 'N/A',
            ),
            if (transaction.endDate != null && transaction.endDate.toString().isNotEmpty) ...[
              const SizedBox(height: 6),
              RecurringDetail(label: 'End Date', value: transaction.endDate!),
            ],
            const SizedBox(height: 6),
            RecurringDetail(
              label: 'Auto Create',
              value: (transaction.autoCreate == true) ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(String status, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  // ============================================================
  // ACTIONS HANDLERS
  // ============================================================

  Future<void> _handleEditRecurring(BuildContext context, dynamic transaction) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => EditRecurring(
        recurringId: transaction.id!,
        accountId: transaction.accountId,
        categoryId: transaction.categoryId,
        type: transaction.type,
        description: transaction.description,
        amount: transaction.amount,
        frequency: transaction.frequency,
        startDate: transaction.startDate,
        endDate: transaction.endDate,
        autoCreate: transaction.autoCreate,
        status: transaction.status,
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      await context.read<RecurringTransactionProvider>().getRecurring();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recurring transaction updated successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _handleDeleteRecurring(BuildContext context, dynamic transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Delete Recurring Transaction?',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${transaction.description ?? 'this transaction'}"?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final provider = context.read<RecurringTransactionProvider>();
    final success = await provider.deleteRecurringTransaction(transaction.id!);

    if (!mounted) return;

    if (success) {
      await provider.getRecurring();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recurring transaction deleted successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to delete recurring transaction'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

// ============================================================
// RECURRING DETAIL ROW HELPER
// ============================================================

class RecurringDetail extends StatelessWidget {
  const RecurringDetail({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}