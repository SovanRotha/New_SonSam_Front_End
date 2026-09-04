import 'package:flutter/material.dart';
import 'package:sansom/widget/category/category_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Widget> pages = [CategoryScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Card(
        child: ListTile(
          leading: const Icon(Icons.category),
          title: const Text('Categories'),
          subtitle: const Text('Manage your categories'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CategoryScreen()),
            );
          },
        ),
      ),
    );
  }
}
