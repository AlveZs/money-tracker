import 'package:money_tracker/domain/repository/money_tx_repository.dart';

import '../entity/money_tx.dart';

class DeleteMoneyTx {
  DeleteMoneyTx({
    required MoneyTxRepository repository,
  }) : _repository = repository;

  final MoneyTxRepository _repository;

  Future<bool> call({ required MoneyTx transaction }) async {
    await _repository.deleteMoneyTx(transaction);

    return true;
  }
}