class Expense {
  final String? id;
  final String title;
  final double amount;
  final String date;

  Expense({this.id, required this.title, required this.amount, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      title: map['title'],
      amount: map['amount'],
      date: map['date'],
    );
  }
}
