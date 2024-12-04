import 'package:money_tracker/data/dto/money_tx_dto.dart';
import 'package:money_tracker/domain/entity/money_tx.dart';
import 'package:money_tracker/domain/repository/money_tx_repository.dart';

import '../../source/local/local_storage.dart';

class MoneyTxRepositoryImpl implements MoneyTxRepository {
  final LocalStorage _localStorage;

  MoneyTxRepositoryImpl({
    required localStorage,
  }) : _localStorage = localStorage;

  @override
  Future<List<MoneyTx>> getTxsByDate({required DateTime date, String? query}) async {
    List<MoneyTx> moneyTxs = _localStorage.loadMoneyTxs(date: date);

    if (query != null) {
      List<MoneyTx> filteredTxs =
          moneyTxs.where((tx) => tx.description.contains(query)).toList();
      moneyTxs = filteredTxs;
    }

    return moneyTxs;
  }

  @override
  Future<bool> addMoneyTx(MoneyTx transaction) {
    return _localStorage.saveMoneyTx(moneyTx: MoneyTxDto(
      description: transaction.description,
      date: transaction.date,
      value: transaction.value,
      isExpense: transaction.isExpense,
    ));
  }

  @override
  Future<bool> deleteMoneyTx(MoneyTx transaction) {
    return _localStorage.removeMoneyTx(moneyTx: MoneyTxDto(
      description: transaction.description,
      date: transaction.date,
      value: transaction.value,
      isExpense: transaction.isExpense,
    ));
  }

  @override
  Future<bool> updateMoneyTx(MoneyTx transaction) {
    // TODO: implement updateMoneyTx
    throw UnimplementedError();
  }
}
