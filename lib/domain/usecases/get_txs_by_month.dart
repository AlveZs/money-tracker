import 'package:money_tracker/domain/entity/money_tx.dart';
import 'package:money_tracker/domain/repository/money_tx_repository.dart';

class GetTxsByMonth {
  GetTxsByMonth({
    required MoneyTxRepository repository,
  }) : _repository = repository;

  final MoneyTxRepository _repository;

  Future<List<MoneyTx>> call({ required DateTime date, String? query }) async {
    final list = await _repository.getTxsByDate(date: date, query: query);

    return list;
  }
}