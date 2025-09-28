import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_provider.dart';
import 'package:intl/intl.dart';

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  DateTime selectedDate = DateTime.now();
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  String selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addExpense(ExpenseProvider provider) {
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    final date = selectedDate.toString().substring(0, 10);

    if (title.isNotEmpty && amount > 0) {
      provider.addExpense(title, amount, date);
      titleController.clear();
      amountController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    // Filter expenses by selected month
    final filteredExpenses = provider.expenses
        .where((exp) => exp.date.startsWith(selectedMonth))
        .toList();

    // Group by date
    final grouped = <String, List<dynamic>>{};
    for (var exp in filteredExpenses) {
      grouped.putIfAbsent(exp.date, () => []).add(exp);
    }
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    // Monthly total
    final monthlyTotal =
        filteredExpenses.fold(0.0, (sum, item) => sum + item.amount);

    // Get all months for dropdown
    final months = provider.expenses
        .map((e) => e.date.substring(0, 7))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Month Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select Month:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                DropdownButton<String>(
                  value: selectedMonth,
                  items: months
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(DateFormat('MMMM yyyy')
                              .format(DateTime.parse("$m-01"))),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedMonth = val;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Monthly Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Total for ${DateFormat('MMMM yyyy').format(DateTime.parse('$selectedMonth-01'))}: Taka ${monthlyTotal.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            // DATE PICKER + INPUT FIELDS
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Expense Type',
                      filled: true,
                      fillColor: Colors.teal[50],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      filled: true,
                      fillColor: Colors.teal[50],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pickDate,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Icon(Icons.calendar_today),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => _addExpense(provider),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Expense List
            Expanded(
              child: filteredExpenses.isEmpty
                  ? const Center(child: Text('No expenses for this month'))
                  : ListView(
                      children: sortedDates.map((date) {
                        final items = grouped[date]!;
                        double dailyTotal =
                            items.fold(0, (sum, item) => sum + item.amount);
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // DATE HEADER WITH DAILY TOTAL
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.teal[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        date,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        'Taka ${dailyTotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // EXPENSE ITEMS
                                ...items.map((exp) {
                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    elevation: 2,
                                    child: ListTile(
                                      title: Text(exp.title),
                                      trailing: Text(
                                          'Taka ${exp.amount.toStringAsFixed(2)}'),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text("Delete Expense"),
                                            content: Text(
                                                "Delete '${exp.title}'?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("Cancel")),
                                              TextButton(
                                                onPressed: () {
                                                  provider.deleteExpense(exp.id!);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "Delete",
                                                  style:
                                                      TextStyle(color: Colors.red),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }).toList()
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
