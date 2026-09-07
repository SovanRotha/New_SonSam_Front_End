import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/account/account_provider.dart';
import 'package:sansom/provider/ai/ai_provider.dart';
import 'package:sansom/provider/account/account_type_provider.dart';
import 'package:sansom/provider/auth/auth_provider.dart';
import 'package:sansom/provider/bill/recurring_transaction_provider.dart';
import 'package:sansom/provider/budget/budget_category_provider.dart';
import 'package:sansom/provider/budget/budget_provider.dart';
import 'package:sansom/provider/category/category_provider.dart';
import 'package:sansom/provider/subscription/subscription_provider.dart';
import 'package:sansom/provider/transaction/transaction_provider.dart';
import 'package:sansom/provider/contribution/contribution_provider.dart';
import 'package:sansom/provider/goal/goal_provider.dart';
import 'package:sansom/provider/subscription/subscription_provider.dart';
import 'package:sansom/view/auth/login.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => BudgetCategoryProvider()),
        ChangeNotifierProvider(create: (_) => AccountTypeProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => RecurringTransactionProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => ContributionProvider()),
        
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
  }
}
