import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:money_tracker/domain/entity/money_tx.dart';

class MoneyTxDto extends MoneyTx {
  MoneyTxDto({
    required super.description,
    required super.value,
    required super.date,
    super.isExpense,
  });

  factory MoneyTxDto.fromRawJson(String str) =>
      MoneyTxDto.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory MoneyTxDto.fromMap(Map<String, dynamic> json) => MoneyTxDto(
        description: json['description'],
        value: json['value'],
        date: DateTime.parse(json['date']),
        isExpense: json['isExpense'],
      );

  Map<String, dynamic> toMap() => {
        'description': description,
        'value': value,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'isExpense': isExpense,
      };
}
