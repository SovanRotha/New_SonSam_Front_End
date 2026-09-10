import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/user/user_provider.dart';
import 'package:sansom/view/profile/edit_user.dart';
import 'package:sansom/view/auth/login.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricEnabled = true; // State for toggle switch demo

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserProvider>().getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'SanSom',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.textPrimary,
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: userProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : userProvider.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      userProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              : user == null
                  ? const Center(
                      child: Text(
                        'No user data',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      // Added large bottom padding so content scrolls clear of the bottom navigation bar
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header Section
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.surface,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neutral.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppColors.border,
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    (user.status ?? 'Premium Member')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Account Management Section
                          const Text(
                            'Account Management',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                _buildSettingsTile(
                                  icon: Icons.person_outline,
                                  iconColor: AppColors.primary,
                                  title: 'Personal Information',
                                  subtitle:
                                      'Update your name, email, and phone',
                                  showDivider: true,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditUser(user: user),
                                      ),
                                    );
                                    if (mounted) {
                                      context.read<UserProvider>().getUser();
                                    }
                                  },
                                ),
                                _buildSettingsTile(
                                  icon: Icons.account_balance_wallet_outlined,
                                  iconColor: AppColors.secondary,
                                  title: 'Linked Institutions',
                                  subtitle:
                                      'Manage bank and credit card connections',
                                  showDivider: false,
                                  onTap: () {
                                    // Add navigation if needed
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Security Section
                          const Text(
                            'Security',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                _buildSettingsTile(
                                  icon: Icons.lock_outline,
                                  iconColor: AppColors.primary,
                                  title: 'Password & Authentication',
                                  subtitle: 'Change password and setup 2FA',
                                  showDivider: true,
                                  onTap: () {
                                    // Add security page navigation
                                  },
                                ),
                                SwitchListTile(
                                  secondary: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.fingerprint,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  title: const Text(
                                    'Biometric Login',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Use Face ID or Fingerprint',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  value: _biometricEnabled,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) {
                                    setState(() {
                                      _biometricEnabled = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Preferences Section
                          const Text(
                            'Preferences',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Appearance',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _buildAppearanceOption(
                                      icon: Icons.light_mode_outlined,
                                      label: 'Light',
                                      isSelected: true,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildAppearanceOption(
                                      icon: Icons.dark_mode_outlined,
                                      label: 'Dark',
                                      isSelected: false,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildAppearanceOption(
                                      icon: Icons.phone_iphone,
                                      label: 'System',
                                      isSelected: false,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: userProvider.isLoading
                                  ? null
                                  : () async {
                                      await userProvider.logout();
                                      if (!mounted) return;

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                        (_) => false,
                                      );
                                    },
                              icon: const Icon(Icons.logout,
                                  color: AppColors.error),
                              label: const Text(
                                'Log Out',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.error.withOpacity(0.08),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  // Reusable list tile helper for section rows
  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool showDivider,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textSecondary,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(height: 1, indent: 60, color: AppColors.border),
      ],
    );
  }

  // Appearance toggle selector helper widget
  Widget _buildAppearanceOption({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}