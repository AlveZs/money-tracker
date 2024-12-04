import 'package:flutter/foundation.dart';
import 'package:money_tracker/domain/repository/money_tx_repository.dart';
import 'package:money_tracker/domain/usecases/add_money_tx.dart';
import 'package:money_tracker/domain/usecases/delete_money_tx.dart';
import 'package:money_tracker/domain/usecases/get_txs_by_month.dart';
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

  DateTime _currentDateTime;
  DateTime get currentDateTime => _currentDateTime;

  final List<MoneyTx> _moneyTxs;
  List<MoneyTx> get moneyTxs => List.unmodifiable(_moneyTxs);

  Future<void> fetchMoneyTxs([String? query]) async {
    _status = MoneyTxListStatus.loading;
    notifyListeners();

    final txList = await GetTxsByMonth(repository: _moneyTxRepository).call(
      month: _currentDateTime.month,
      query: query,
    );
    _moneyTxs.clear();
    _moneyTxs.addAll(txList);
    _status = MoneyTxListStatus.success;
    notifyListeners();
  }

  Future<void> createMoneyTx(MoneyTx moneyTx) async {
    await AddMoneyTx(
      repository: _moneyTxRepository,
    ).call(moneyTx: moneyTx);
    _moneyTxs.add(moneyTx);
    notifyListeners();
  }

  Future<void> deleteTx(MoneyTx moneyTx) async {
    await DeleteMoneyTx(
      repository: _moneyTxRepository,
    ).call(transaction: moneyTx);
    _moneyTxs.remove(moneyTx);
    notifyListeners();
  }

  Future<void> updateTx(MoneyTx moneyTx) async {
    MoneyTx originalTx = _moneyTxs.firstWhere((tx) => tx.id == moneyTx.id);
    int txIndex = _moneyTxs.indexOf(originalTx);
    _moneyTxs[txIndex] = moneyTx;
    await UpdateMoneyTx(
      repository: _moneyTxRepository,
    ).call(moneyTx: moneyTx);
    notifyListeners();
  }

  Future<void> changeDate(DateTime dateTime) async {
    _currentDateTime = dateTime;
    await fetchMoneyTxs();
    notifyListeners();
  }
}
