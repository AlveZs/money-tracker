import 'dart:async';

import 'package:money_tracker/data/models/money/money_tx.dart';

Future<List<MoneyTx>> getTransactions() {
  return Future.delayed(
    const Duration(seconds: 5),
    () => ([
      MoneyTx('FULANO DE TAL', 100, DateTime.now()),
      MoneyTx('CICRANO', 100, DateTime.now(), isExpense: true),
    ]),
  );
}

List<String> monthsNames = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro'
];
