import 'package:cloud_firestore/cloud_firestore.dart';
import 'expense_model.dart';

class FirebaseService {
  final CollectionReference expensesRef =
      FirebaseFirestore.instance.collection('expenses');

  Future<void> addExpense(Expense expense) async {
    await expensesRef.add(expense.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    final snapshot = await expensesRef.get();
    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Stream<List<Expense>> expenseStream() {
    return expensesRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Expense.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }
}
