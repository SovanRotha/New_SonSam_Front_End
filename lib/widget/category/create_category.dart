import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/category/category_provider.dart';

class CreateCategory extends StatefulWidget {
  const CreateCategory({super.key});

  @override
  State<CreateCategory> createState() => _CreateCategoryState();
}

class _CreateCategoryState extends State<CreateCategory> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.read<CategoryProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Create Category',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: typeController.text.isEmpty ? null : typeController.text,
            decoration: const InputDecoration(
              labelText: 'Category Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'income', child: Text('Income')),
              DropdownMenuItem(value: 'expense', child: Text('Expense')),
            ],
            onChanged: (value) {
              typeController.text = value ?? '';
            },
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),

              const SizedBox(width: 8),

              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final type = typeController.text.trim();

                  if (name.isEmpty || type.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter category name and type'),
                      ),
                    );
                    return;
                  }

                  final categoryData = {
                    'name': name,
                    'type': type,
                    'parent_id': null,
                  };

                  await categoryProvider.createCategory(categoryData);

                  if (categoryProvider.errorMessage != null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(categoryProvider.errorMessage!)),
                      );
                    }
                    return;
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
