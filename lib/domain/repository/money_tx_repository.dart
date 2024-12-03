import 'package:money_tracker/domain/entity/money_tx.dart';

abstract class MoneyTxRepository {
  Future<List<MoneyTx>> getTxsByMonth({int month = 0, String? query});
  Future<bool> addMoneyTx(MoneyTx transaction);
  Future<bool> deleteMoneyTx(MoneyTx transaction);
  Future<bool> updateMoneyTx(MoneyTx transaction);
}