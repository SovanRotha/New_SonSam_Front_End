
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sansom/provider/category/category_provider.dart';
import 'package:sansom/widget/category/create_category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().getCategory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showCreateCategoryDialog(context);
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: _buildBody(categoryProvider),
    );
  }

  Widget _buildBody(CategoryProvider categoryProvider) {
    // Loading
    if (categoryProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error
    if (categoryProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),

              const SizedBox(height: 12),

              Text(
                categoryProvider.errorMessage!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  categoryProvider.getCategory();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (categoryProvider.categories.isEmpty) {
      return _buildEmptyState();
    }

    // Category list
    return RefreshIndicator(
      onRefresh: () async {
        await categoryProvider.getCategory();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categoryProvider.categories.length,
        itemBuilder: (context, index) {
          final category =
              categoryProvider.categories[index];

          return _buildCategoryCard(
            context,
            category,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_outlined,
                size: 60,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Categories Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Create categories to organize your income and expenses.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                _showCreateCategoryDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Category'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    dynamic category,
  ) {
    final bool isIncome =
        category.type.toLowerCase() == 'income';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            // Category information
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  _buildTypeBadge(
                    category.type,
                    isIncome,
                  ),
                ],
              ),
            ),

            // More menu
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog(
                    context,
                    category.id,
                    category.name,
                  );
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(
    String type,
    bool isIncome,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isIncome
                ? Icons.trending_up
                : Icons.trending_down,
            size: 14,
            color: Colors.grey.shade700,
          ),

          const SizedBox(width: 5),

          Text(
            type,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCategoryDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return const Dialog(
          child: CreateCategory(),
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    int categoryId,
    String categoryName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Category?',
          ),

          content: Text(
            'Are you sure you want to delete "$categoryName"?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await context
                    .read<CategoryProvider>()
                    .deleteCategory(categoryId);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

