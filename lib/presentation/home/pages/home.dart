import 'package:flutter/material.dart';
import 'package:money_tracker/balance_chart.dart';
import 'package:money_tracker/presentation/home/widgets/home_date_picker.dart';
import 'package:money_tracker/presentation/home/widgets/money_info_tile.dart';
import 'package:money_tracker/presentation/home/widgets/transactions_list.dart';
import 'package:money_tracker/presentation/provider/money_tx_provider.dart';
import 'package:provider/provider.dart';

import '../../../domain/entity/money_tx.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Future<List<MoneyTx>>? _moneyTxs;
  List<MoneyTx> _moneyTxs = [];
  // late GetTxsByMonth _getTxsByMonth;

  @override
  void initState() {
    super.initState();
    //_moneyTxs = getTransactions();
    // final localStorage = LocalStorageImpl(sharedPreferences: sharedPref);
    // final repo = MoneyTxRepositoryImpl(localStorage: localStorage);

    //_getTxsByMonth = GetTxsByMonth(repository: repo);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      //_moneyTxs = getTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoneyTxProvider>(
        builder: (context, moneyTxNotifier, child) {
      _moneyTxs = moneyTxNotifier.moneyTxs;
      DateTime currentDateTime = moneyTxNotifier.currentDateTime;
      MoneyTxListStatus txsFetchStatus = moneyTxNotifier.status;
      double txsSum = _moneyTxs.fold(0, (sum, tx) => sum + tx.value);
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        notificationPredicate: (ScrollNotification notification) {
          if (notification is OverscrollNotification) {
            return true;
          }

          return notification.depth == 0;
        },
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    HomeDatePicker(
                      date: currentDateTime,
                      changeDate: moneyTxNotifier.changeDate,
                    ),
                    Row(
                      children: [
                        MoneyInfoTile(
                            description: "Balanço do Mês", value: txsSum),
                      ],
                    ),
                    const Divider(),
                    const BalanceChart(),
                    const Divider(),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                sliver: SliverAppBar(
                  collapsedHeight: 90,
                  flexibleSpace: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SearchBar(
                      hintText: 'Buscar',
                      leading: const Icon(Icons.search),
                      onChanged: (queryString) {
                        if (queryString.length > 3) {
                          moneyTxNotifier.fetchMoneyTxs(queryString);
                        } else {
                          moneyTxNotifier.fetchMoneyTxs();
                        }
                      },
                    ),
                  ),
                  backgroundColor: Theme.of(context).canvasColor,
                  surfaceTintColor: Theme.of(context).canvasColor,
                  pinned: true,
                ),
              ),
            ];
          },
          body: TransactionsList(
            moneyTxs: _moneyTxs,
            txsFetchStatus: txsFetchStatus,
            deleteTransaction: moneyTxNotifier.deleteTx,
          ),
        ),
      );
    });
  }
}
