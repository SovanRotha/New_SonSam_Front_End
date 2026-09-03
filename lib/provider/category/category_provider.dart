

import 'package:flutter/material.dart';
import 'package:sansom/models/category/category_model.dart';
import 'package:sansom/service/category/category_service.dart';

class CategoryProvider extends ChangeNotifier {

  final CategoryService categoryService = CategoryService();

  List<Category> categories = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> getCategory() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await categoryService.getCategory();

      final List<dynamic> categoryData = response['categories'];

      categories = categoryData
          .map((json) => Category.fromJson(json))
          .toList();

    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> createCategory(Map<String, dynamic> categoryData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await categoryService.createCategory(categoryData);

      if (response['categories'] != null) {
        categories.add(
          Category.fromJson(response['categories']),
        );
      }

    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateCategory(int id, Map<String, dynamic> categoryData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await categoryService.updateCategory(id, categoryData);

      if (response['categories'] != null) {
        final index = categories.indexWhere((category) => category.id == id);
        if (index != -1) {
          categories[index] = Category.fromJson(response['categories']);
        }
      }

    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCategory(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await categoryService.deleteCategory(id);

      categories.removeWhere((category) => category.id == id);

    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }


}