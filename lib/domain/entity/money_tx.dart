class MoneyTx {
  String? id;
  String description;
  double value;
  DateTime date;
  bool isExpense;

  MoneyTx({
    required this.description,
    required this.value,
    required this.date,
    this.id,
    this.isExpense = false,
  });
}
