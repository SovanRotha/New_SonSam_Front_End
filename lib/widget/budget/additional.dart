import 'package:flutter/material.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/view/bill/bill_screen.dart';
import 'package:sansom/view/bill/recurring_screen.dart';
import 'package:sansom/view/bill/subscribtion_screen.dart';

class Additional extends StatelessWidget {
  final int initialIndex; // Add this parameter
  
  const Additional({super.key, this.initialIndex = 0}); // Default to 0 (Bills)

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialIndex, // Set the initial tab index here
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text(
            'Additional Features',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: AppColors.surface,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TabBar(
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Bills'),
                  Tab(text: 'Subscriptions'),
                  Tab(text: 'Recurring'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            BillScreen(),
            SubscribtionScreen(),
            RecurringScreen(),
          ],
        ),
      ),
    );
  }
}