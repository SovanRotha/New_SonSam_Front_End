import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/transaction/transaction_provider.dart';
import 'package:sansom/provider/user/user_provider.dart';
import 'package:sansom/service/token/token_storage.dart';
import 'package:sansom/view/ai/ai_screen.dart';
import 'package:sansom/view/goal/goal_screen.dart';
import 'package:sansom/view/history/history_screen.dart';
import 'package:sansom/widget/Account/Account_screen.dart';
import 'package:sansom/widget/budget/additional.dart';
import 'package:sansom/widget/category/category_screen.dart';
import 'package:sansom/widget/notification/notification.dart';
import 'package:sansom/widget/transaction/chart_transaction.dart';
import 'package:sansom/widget/transaction/summary_transaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Account',
      'subtitle': 'Manage your primary financial accounts & balances',
      'icon': Icons.account_balance_wallet_rounded,
      'screen': const AccountScreen(),
    },
    {
      'title': 'Category',
      'subtitle': 'Organize your income and expense categories',
      'icon': Icons.category_outlined,
      'screen': const CategoryScreen(),
    },
    {
      'title': 'Bill',
      'subtitle': 'Manage your bills and recurring payments',
      'icon': Icons.receipt_long_rounded,
      'screen': const Additional(initialIndex: 0),
    },
    {
      'title': 'Subscription',
      'subtitle': 'Manage your subscriptions and recurring payments',
      'icon': Icons.subscriptions_rounded,
      'screen': const Additional(initialIndex: 1),
    },
    {
      'title': 'Recurring Transaction',
      'subtitle': 'Manage your recurring transactions',
      'icon': Icons.repeat_rounded,
      'screen': const Additional(initialIndex: 2),
    },
    {
      'title': 'Saving Goal',
      'subtitle': 'Set and track your saving goals',
      'icon': Icons.savings_rounded,
      'screen': const GoalScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userProvider = context.read<UserProvider>();
      if (userProvider.user == null) {
        userProvider.getUser();
      }
      _loadTransactions();
    });
  }

  Future _loadTransactions() async {
    final token = await TokenStorage.getToken();
    if (!mounted || token == null || token.isEmpty) return;

    await context.read<TransactionProvider>().loadTransactions(token);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final recentTransactions = transactionProvider.transactions.reversed
        .take(5)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'SanSom',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: const Icon(
              Icons.person,
              color: AppColors.textLight,
              size: 20,
            ),
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 80,
        ),
        children: [
          // Greeting Block
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Welcome, ',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: userProvider.user?.name ?? 'User',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),


              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. AI Assistant Card
          _buildAIChatCard(context),
          const SizedBox(height: 24),

          const SummaryTransaction(),

          const SizedBox(height: 20,),

          const TransactionChart(),

          const SizedBox(height: 20,),

          // 2. Quick Management Section Header
          const Text(
            'Quick Management',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Management Menu Grid (Bank Style)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: menuItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
              mainAxisExtent: 90,
            ),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _buildMenuGridCard(context, item);
            },
          ),

          // Proper controlled space between grid and next section
          const SizedBox(height: 12),

          // 3. Recent Transactions Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 8),

          _buildRecentTransactions(transactionProvider, recentTransactions),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(
    TransactionProvider provider,
    List transactions,
  ) {
    if (provider.isLoading && transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (provider.errorMessage != null && transactions.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          provider.errorMessage!,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No transactions yet.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: transactions.map((transaction) {
        final isIncome = transaction.type.trim().toLowerCase() == 'income';
        final title = transaction.description?.isNotEmpty == true
            ? transaction.description!
            : transaction.category?.name ?? 'Transaction';
        final category = transaction.category?.name ?? transaction.type;
        final amount =
          '${isIncome ? '+' : '-'}\$${transaction.amount.abs().toStringAsFixed(2)}';
        return _buildTransactionCard(
          title: title,
          category: category,
          amount: amount,
          isIncome: isIncome,
          date: transaction.transactionDate.split(' ').first,
        );
      }).toList(),
    );
  }

  Widget _buildAIChatCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AiScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'SanSom AI Advisor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ask questions about your spending habits & get insights',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGridCard(BuildContext context, Map item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item['screen']),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item['icon'], color: AppColors.primary, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String category,
    required String amount,
    required bool isIncome,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isIncome ? Colors.green : Colors.redAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\(category •\)date',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
