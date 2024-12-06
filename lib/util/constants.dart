import 'dart:async';
import 'dart:math';

import 'package:money_tracker/data/models/money/money_tx.dart';

import '../domain/entity/month_balance.dart';

var rng = Random();

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

// CHART

const double CHART_HEIGHT = 30;

final List<MonthBalance> fakeBalance = List<MonthBalance>.generate(
  12,
  (mb) => MonthBalance(
      income: rng.nextInt(100).toDouble(),
      expenses: rng.nextInt(100).toDouble()),
  growable: false,
);
