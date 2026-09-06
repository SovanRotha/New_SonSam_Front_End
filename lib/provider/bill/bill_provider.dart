import 'package:flutter/material.dart';
import 'package:sansom/models/bill/bill_model.dart';
import 'package:sansom/service/bill/bill_service.dart';

class BillProvider extends ChangeNotifier {
  final BillService billService = BillService();

  List<BillModel> bills = [];

  bool isLoading = false;
  String? errorMessage;

  // =========================
  // GET BILLS
  // =========================

  Future<void> getBills() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await billService.getBills();

      final List<dynamic> billData = response['bills'] ?? [];

      bills = billData
          .map((json) => BillModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // =========================
  // GET ONE BILL
  // =========================

  Future<BillModel?> getBill(int id) async {
    try {
      final response = await billService.getBill(id);

      if (response['bill'] != null) {
        return BillModel.fromJson(response['bill']);
      }

      return null;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // =========================
  // CREATE BILL
  // =========================

  Future<bool> createBill(Map<String, dynamic> billData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await billService.createBill(billData);

      if (response['bill'] != null) {
        bills.insert(0, BillModel.fromJson(response['bill']));
      }

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // =========================
  // UPDATE BILL
  // =========================

  Future<bool> updateBill(int id, Map<String, dynamic> billData) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await billService.updateBill(id, billData);

      if (response['bill'] != null) {
        final updatedBill = BillModel.fromJson(response['bill']);

        final index = bills.indexWhere((bill) => bill.id == id);

        if (index != -1) {
          bills[index] = updatedBill;
        }
      }

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // =========================
  // DELETE BILL
  // =========================

  Future<bool> deleteBill(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await billService.deleteBill(id);

      bills.removeWhere((bill) => bill.id == id);

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();

      return false;
    }
  }
}
