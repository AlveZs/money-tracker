class MoneyTx {
  String description;
  double value;
  DateTime date;
  bool isExpense;

  MoneyTx(this.description, this.value, this.date, {this.isExpense = false});
}
