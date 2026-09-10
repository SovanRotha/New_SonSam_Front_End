import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/category/category_provider.dart';

class EditCategory extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final String categoryType;

  const EditCategory({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
  });

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  late TextEditingController nameController;

  String selectedType = 'expense';

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.categoryName,
    );

    selectedType = widget.categoryType.toLowerCase();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> updateCategory() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category name is required'),
        ),
      );
      return;
    }

    final categoryData = {
      'name': name,
      'type': selectedType,
    };

    final provider = context.read<CategoryProvider>();

    await provider.updateCategory(
      widget.categoryId,
      categoryData,
    );

    if (!mounted) return;

    if (provider.errorMessage == null) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category updated successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Category',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'income',
                child: Text('Income'),
              ),
              DropdownMenuItem(
                value: 'expense',
                child: Text('Expense'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedType = value;
                });
              }
            },
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: provider.isLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                child: const Text('Cancel'),
              ),

              const SizedBox(width: 8),

              ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : updateCategory,
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}