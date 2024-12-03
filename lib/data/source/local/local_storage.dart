import 'package:flutter/material.dart';
import 'package:money_tracker/data/dto/money_tx_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

const moneyTxsListKey = 'MONEY_TXS_LIST_MONTH';

abstract class LocalStorage {
  Future<bool> saveMoneyTxPage({
    required int month,
    required List<MoneyTxDto> list,
  });


  Future<bool> saveMoneyTx({
    required MoneyTxDto moneyTx,
  });

  Future<bool> removeMoneyTx({ required MoneyTxDto moneyTx, });

  List<MoneyTxDto> loadMoneyTxs({required int month});
}

class LocalStorageImpl implements LocalStorage {
  final SharedPreferences _sharedPref;

  LocalStorageImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPref = sharedPreferences;

  @override
  List<MoneyTxDto> loadMoneyTxs({required int month}) {
    final key = getKeyToMonth(month);
    final jsonList = _sharedPref.getStringList(key);

    return jsonList != null
        ? jsonList.map((e) => MoneyTxDto.fromRawJson(e)).toList()
        : [];
  }

  @override
  Future<bool> saveMoneyTxPage({
    required int month,
    required List<MoneyTxDto> list,
  }) {
    final jsonList = list.map((e) => e.toRawJson()).toList();
    final key = getKeyToMonth(month);
    return _sharedPref.setStringList(key, jsonList);
  }

  @override
  Future<bool> saveMoneyTx({ required MoneyTxDto moneyTx }) {
    final jsonTx = moneyTx.toRawJson();
    final key = getKeyToMonth(moneyTx.date.month);
    final jsonList = _sharedPref.getStringList(key) ?? [];
    jsonList.add(jsonTx);
    return _sharedPref.setStringList(key, jsonList);
  }

  @visibleForTesting
  static String getKeyToMonth(int month) {
    return '${moneyTxsListKey}_$month';
  }
  
  @override
  Future<bool> removeMoneyTx({required MoneyTxDto moneyTx}) {
    final key = getKeyToMonth(moneyTx.date.month);
    final jsonList = _sharedPref.getStringList(key) ?? [];
    jsonList.remove(moneyTx.toRawJson());

    return _sharedPref.setStringList(key, jsonList);
  }
}
