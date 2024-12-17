import 'package:flutter/foundation.dart';
import 'package:money_tracker/domain/entity/month_balance.dart';
import 'package:money_tracker/domain/repository/money_tx_repository.dart';
import 'package:money_tracker/domain/usecases/add_money_tx.dart';
import 'package:money_tracker/domain/usecases/delete_money_tx.dart';
import 'package:money_tracker/domain/usecases/get_txs_by_date.dart';
import 'package:money_tracker/domain/usecases/update_money_tx.dart';

import '../../domain/entity/money_tx.dart';

enum MoneyTxListStatus { initial, loading, success, failed }

class MoneyTxProvider extends ChangeNotifier {
  MoneyTxProvider({
    // required GetTxsByMonth getTxsByMonth,
    // required DeleteMoneyTx deleteMoneyTx,
    // required AddMoneyTx addMoneyTx,
    // required UpdateMoneyTx updateMoneyTx,
    required MoneyTxRepository moneyTxRepository,
    List<MoneyTx>? moneyTxs,
    DateTime? currentDateTime,
    MoneyTxListStatus? initialStatus,
  })  : //_getTxsByMonth = getTxsByMonth,
        //_deleteMoneyTx = deleteMoneyTx,
        //_addMoneyTx = addMoneyTx,
        //_updateMoneyTx = updateMoneyTx,
        _moneyTxRepository = moneyTxRepository,
        _moneyTxs = moneyTxs ?? [],
        _currentDateTime = currentDateTime ?? DateTime.now(),
        _status = initialStatus ?? MoneyTxListStatus.initial;

  late final MoneyTxRepository _moneyTxRepository;
  // final GetTxsByMonth _getTxsByMonth;
  // final AddMoneyTx _addMoneyTx;
  // final DeleteMoneyTx _deleteMoneyTx;
  // final UpdateMoneyTx _updateMoneyTx;

  MoneyTxListStatus _status;
  MoneyTxListStatus get status => _status;

  MoneyTxListStatus _chartStatus = MoneyTxListStatus.initial;
  MoneyTxListStatus get chartStatus => _chartStatus;

  final List<MonthBalance> _balanceInYear = List<MonthBalance>.generate(
    12,
    (mb) => MonthBalance(income: 0, expenses: 0),
    growable: false,
  );
  List<MonthBalance> get balanceInYear => _balanceInYear;

  DateTime _currentDateTime;
  DateTime get currentDateTime => _currentDateTime;

  final List<MoneyTx> _moneyTxs;
  List<MoneyTx> get moneyTxs => List.unmodifiable(_moneyTxs);

  Future<void> initNotifier() async {
    await fetchMoneyTxs(_currentDateTime);
    await fetchYearBalance(_currentDateTime);
  }

  Future<void> fetchYearBalance(DateTime date) async {
    _chartStatus = MoneyTxListStatus.loading;
    notifyListeners();
    final List<MoneyTx> allTx = [];

    for (var i = 1; i < 13; i++) {
      final txList = await GetTxsByMonth(repository: _moneyTxRepository).call(
          date: DateTime(
        date.year,
        i,
      ));
      allTx.addAll(txList);
    }

    for (MonthBalance balance in _balanceInYear) {
      balance.income = 0;
      balance.expenses = 0;
    }

    for (MoneyTx tx in allTx) {
      tx.isExpense
          ? _balanceInYear[tx.date.month - 1].expenses += tx.value
          : _balanceInYear[tx.date.month - 1].income += tx.value;
    }

    for (var i = 0; i < _balanceInYear.length; i++) {
      print(
          'Mês $i: Receita: ${_balanceInYear[i].income}, Despesas: ${_balanceInYear[i].expenses}');
    }

    _chartStatus = MoneyTxListStatus.success;
    
    notifyListeners();
  }

  Future<void> fetchMoneyTxs(DateTime currentDate, [String? query]) async {
    _status = MoneyTxListStatus.loading;
    notifyListeners();

    final txList = await GetTxsByMonth(repository: _moneyTxRepository).call(
      date: currentDate,
      query: query,
    );
    _moneyTxs.clear();
    _moneyTxs.addAll(txList);
    _status = MoneyTxListStatus.success;
    notifyListeners();
  }

  Future<bool> createMoneyTx(MoneyTx moneyTx) async {
    bool result = await AddMoneyTx(
      repository: _moneyTxRepository,
    ).call(moneyTx: moneyTx);
    if (moneyTx.date.year == _currentDateTime.year) {
      if (moneyTx.date.month == _currentDateTime.month) {
        _moneyTxs.add(moneyTx);
      }
      moneyTx.isExpense
          ? _balanceInYear[moneyTx.date.month - 1].expenses += moneyTx.value
          : _balanceInYear[moneyTx.date.month - 1].income += moneyTx.value;
    }
    notifyListeners();

    return result;
  }

  Future<bool> deleteTx(MoneyTx moneyTx) async {
    bool result = await DeleteMoneyTx(
      repository: _moneyTxRepository,
    ).call(transaction: moneyTx);
    _moneyTxs.remove(moneyTx);
    moneyTx.isExpense
        ? _balanceInYear[moneyTx.date.month - 1].expenses -= moneyTx.value
        : _balanceInYear[moneyTx.date.month - 1].income -= moneyTx.value;
    notifyListeners();

    return result;
  }

  Future<bool> updateTx(MoneyTx moneyTx) async {
    bool result = await UpdateMoneyTx(
      repository: _moneyTxRepository,
    ).call(moneyTx: moneyTx);

    MoneyTx originalTx = _moneyTxs.firstWhere((tx) => tx.id == moneyTx.id);
    int txIndex = _moneyTxs.indexOf(originalTx);
    if (txIndex > -1) {
      if (_currentDateTime.month == moneyTx.date.month) {
        _moneyTxs[txIndex] = moneyTx;
      } else {
        _moneyTxs.removeAt(txIndex);
      }
    }
    notifyListeners();

    return result;
  }

  Future<void> changeDate(DateTime dateTime) async {
    _currentDateTime = dateTime;
    notifyListeners();
  }
}
