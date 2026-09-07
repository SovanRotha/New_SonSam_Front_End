import 'package:flutter/material.dart';
import 'package:sansom/widget/Account/Account_screen.dart';
import 'package:sansom/widget/Account/account_type_screen.dart';
import 'package:sansom/widget/category/category_screen.dart';
import 'package:sansom/widget/contribution/contribution_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Widget> pages = [
    CategoryScreen(),
    AccountScreen(),
    AccountTypeScreen(),
    
    ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Card(
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.category),
              
              trailing: const Icon(Icons.arrow_forward_ios),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => pages[index],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
