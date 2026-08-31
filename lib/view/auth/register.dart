// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sansom/provider/auth/auth_provider.dart';
// import 'package:sansom/widget/custom_bottom_nav.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();

//   String? selectedCurrency;

//   Future<void> register() async {
//     final provider = context.read<AuthProvider>();

//     if (selectedCurrency == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Please choose a currency')));
//       return;
//     }

//     final success = await provider.register(
//       nameController.text.trim(),
//       emailController.text.trim(),
//       passwordController.text,
//       phoneController.text.trim(),
//       selectedCurrency!,
//     );

//     if (success) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => CustomBottomNav()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(provider.errorMessage ?? 'Registration failed')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Register")),

//       body: Column(
//         children: [
//           TextFormField(
//             controller: nameController,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               hintText: "Enter Your Name",
//             ),
//           ),

//           SizedBox(height: 20),

//           TextFormField(
//             controller: emailController,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               hintText: "Enter Your Email",
//             ),
//           ),

//           SizedBox(height: 20),

//           TextFormField(
//             controller: passwordController,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               hintText: "Enter Your Password",
//             ),
//           ),

//           SizedBox(height: 20),

//           TextFormField(
//             controller: phoneController,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               hintText: "Enter Your Phone Number",
//             ),
//           ),

//           SizedBox(height: 20),

//           DropdownButtonFormField<String>(
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(),
//               labelText: 'Currency',
//             ),
//             hint: const Text('Choose Currency'),
//             items: const [
//               DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
//               // DropdownMenuItem(
//               //   value: 'KHR',
//               //   child: Text('KHR - Cambodian Riel'),
//               // ),
//             ],
//             onChanged: (value) {
//               setState(() {
//                 selectedCurrency = value;
//               });
//             },
//           ),

//           SizedBox(height: 20),

//           ElevatedButton(
//             onPressed: register,
//             child: Text("Register")),
//         ],
//       ),
//     );
//   }
// }


import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/core/constant/app_color.dart';
import 'package:sansom/provider/auth/auth_provider.dart';
import 'package:sansom/widget/custom_bottom_nav.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedCurrency;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (selectedCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a currency'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final provider = context.read<AuthProvider>();

    final success = await provider.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
      phoneController.text.trim(),
      selectedCurrency!,
    );

    setState(() => _isLoading = false);

    if (success) {
      log('Successfully registered');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CustomBottomNav()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Title
                const Text(
                  "SanSom",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Create your account to get started.",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Main Card Container
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name Field Label
                      const Text(
                        "Full Name",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: _buildInputDecoration(
                          hintText: "Alex Morgan",
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Address Field Label
                      const Text(
                        "Email Address",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(
                          hintText: "alex@example.com",
                          prefixIcon: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field Label
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: _buildInputDecoration(
                          hintText: "••••••••",
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone Number Field Label
                      const Text(
                        "Phone Number",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _buildInputDecoration(
                          hintText: "012345678",
                          prefixIcon: Icons.phone_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Currency Dropdown Label
                      const Text(
                        "Currency",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedCurrency,
                        hint: const Text(
                          "Choose Currency",
                          style: TextStyle(color: AppColors.disabled),
                        ),
                        decoration: _buildInputDecoration(
                          hintText: "",
                          prefixIcon: Icons.attach_money_rounded,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'USD',
                            child: Text('USD - US Dollar'),
                          ),
                          // DropdownMenuItem(
                          //   value: 'KHR',
                          //   child: Text('KHR - Cambodian Riel'),
                          // ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCurrency = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Register Button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.textLight,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textLight,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Already have an account Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Terms and Privacy Text
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(text: "By registering, you agree to our "),
                      TextSpan(
                        text: "Terms of Service",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: " and\n"),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: "."),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper decoration method to keep input field styles consistent
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.disabled),
      prefixIcon: Icon(
        prefixIcon,
        color: AppColors.textSecondary,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14.0,
        horizontal: 12.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}