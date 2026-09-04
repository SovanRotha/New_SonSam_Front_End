import 'package:flutter/material.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/view/ai/ai_screen.dart';
import 'package:sansom/view/budget/budget_screen.dart';
import 'package:sansom/view/goal/goal_screen.dart';
import 'package:sansom/view/history/history_screen.dart';
import 'package:sansom/view/home/home_screen.dart';
import 'package:sansom/view/profile/profile_screen.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int selectedIndex = 0;

  final List<Widget> screens =  [
    HomeScreen(),
    HistoryScreen(),
    BudgetScreen(),
    GoalScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: screens[selectedIndex],

      // AI Robot Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open AI Assistant screen or bottom sheet
          //============================================//
          Navigator.push(context, MaterialPageRoute(builder: (context)=> AiScreen()));
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.smart_toy_rounded, // AI / Robot icon
          color: AppColors.textLight,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.surface,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedFontSize: 11,
              unselectedFontSize: 10,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              elevation: 0,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_outlined, size: 24),
                  ),
                  activeIcon: _buildActiveIcon(Icons.home_rounded),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.history_outlined, size: 24),
                  ),
                  activeIcon: _buildActiveIcon(Icons.history_rounded),
                  label: "History",
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.account_balance_wallet_outlined, size: 24),
                  ),
                  activeIcon: _buildActiveIcon(Icons.account_balance_wallet_rounded),
                  label: "Budget",
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.track_changes_outlined, size: 24),
                  ),
                  activeIcon: _buildActiveIcon(Icons.track_changes_rounded),
                  label: "Goals",
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.person_outline, size: 24),
                  ),
                  activeIcon: _buildActiveIcon(Icons.person_rounded),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        size: 22,
        color: AppColors.primary,
      ),
    );
  }
}