import 'package:money_tracker/domain/repository/money_tx_repository.dart';

import '../entity/money_tx.dart';

class AddMoneyTx {
  AddMoneyTx({
    required MoneyTxRepository repository,
  }) : _repository = repository;

  final MoneyTxRepository _repository;

  Future<bool> call({ required MoneyTx moneyTx }) async {
    await _repository.addMoneyTx(moneyTx);

    return true;
  }
}