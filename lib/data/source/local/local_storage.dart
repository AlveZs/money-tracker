import 'package:flutter/material.dart';
import 'package:money_tracker/data/dto/money_tx_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

const moneyTxsListKey = 'MONEY_TXS_LIST_DATE';

abstract class LocalStorage {
  Future<bool> saveMoneyTx({
    required MoneyTxDto moneyTx,
  });

  Future<bool> updateMoney({
    required MoneyTxDto moneyTx,
  });

  MoneyTxDto? getMoneyTxById({
    required String transactionId,
  });

  Future<bool> removeMoneyTx({
    required MoneyTxDto moneyTx,
  });

  List<MoneyTxDto> loadMoneyTxs({required DateTime date});
}

class LocalStorageImpl implements LocalStorage {
  final SharedPreferences _sharedPref;

  LocalStorageImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPref = sharedPreferences;

  @override
  List<MoneyTxDto> loadMoneyTxs({required DateTime date}) {
    final key = getKeyByDate(date);
    final jsonList = _sharedPref.getStringList(key);

    return jsonList != null
        ? jsonList.map((e) => MoneyTxDto.fromRawJson(e)).toList()
        : [];
  }

  @override
  Future<bool> saveMoneyTx({required MoneyTxDto moneyTx}) {
    final jsonTx = moneyTx.toRawJson();
    final key = getKeyByDate(moneyTx.date);
    final jsonList = _sharedPref.getStringList(key) ?? [];
    jsonList.add(jsonTx);
    return _sharedPref.setStringList(key, jsonList);
  }

  @visibleForTesting
  static String getKeyByDate(DateTime date) {
    return '${moneyTxsListKey}_${date.month}_${date.year}';
  }

  @override
  Future<bool> removeMoneyTx({required MoneyTxDto moneyTx}) {
    final key = getKeyByDate(moneyTx.date);
    final jsonList = _sharedPref.getStringList(key) ?? [];
    jsonList.remove(moneyTx.toRawJson());

    return _sharedPref.setStringList(key, jsonList);
  }

  @override
  Future<bool> updateMoney({required MoneyTxDto moneyTx}) async {
    final originalTx = getMoneyTxById(transactionId: moneyTx.id!);
    final jsonTx = moneyTx.toRawJson();
    final key = getKeyByDate(moneyTx.date);
    final jsonList = _sharedPref.getStringList(key) ?? [];
    if (originalTx != null && originalTx.date.month != moneyTx.date.month) {
      await removeMoneyTx(moneyTx: originalTx);
    } else {
      jsonList
          .removeWhere((jsTx) => MoneyTxDto.fromRawJson(jsTx).id == moneyTx.id);
    }
    jsonList.add(jsonTx);

    return _sharedPref.setStringList(key, jsonList);
  }

  @override
  MoneyTxDto? getMoneyTxById({required String transactionId}) {
    for (var listKeys in _sharedPref.getKeys()) {
      if (listKeys.contains('MONEY_TXS_LIST_DATE')) {
        final jsonList = _sharedPref.getStringList(listKeys) ?? [];
        final List<MoneyTxDto> txsList =
            jsonList.map((e) => MoneyTxDto.fromRawJson(e)).toList();
        final MoneyTxDto? foundTx =
            txsList.firstWhereOrNull((tx) => tx.id == transactionId);
        if (foundTx != null) {
          return foundTx;
        }
      }
    }

    return null;
  }
}
