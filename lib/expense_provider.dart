import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';
import 'expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  Future<void> loadExpenses() async {
    _expenses = await _firebaseService.getExpenses();
    notifyListeners();
  }

  Future<void> addExpense(String title, double amount, String date) async {
    final expense = Expense(title: title, amount: amount, date: date);
    await _firebaseService.addExpense(expense);
    await loadExpenses();
  }

  double getMonthlyTotal(String month) {
    return _expenses
        .where((e) => e.date.startsWith(month))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  void listenToExpenses() {
    _firebaseService.expenseStream().listen((data) {
      _expenses = data;
      notifyListeners();
    });
  }

  Future<void> deleteExpense(String id) async {
  await FirebaseFirestore.instance.collection('expenses').doc(id).delete();
  _expenses.removeWhere((e) => e.id == id);
  notifyListeners();
}

}
