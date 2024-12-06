import 'package:flutter/material.dart';
import 'package:money_tracker/balance_chart.dart';
import 'package:money_tracker/domain/entity/month_balance.dart';
import 'package:money_tracker/presentation/home/widgets/home_date_picker.dart';
import 'package:money_tracker/presentation/home/widgets/money_info_tile.dart';
import 'package:money_tracker/presentation/home/widgets/transactions_list.dart';
import 'package:money_tracker/presentation/provider/money_tx_provider.dart';
import 'package:money_tracker/util/constants.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoneyTxProvider>().fetchYearBalance(DateTime.now());
    }); */
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
      MoneyTxListStatus chartFetchStatus = moneyTxNotifier.chartStatus;
      print(chartFetchStatus);
      List<MonthBalance> yearBalance = moneyTxNotifier.balanceInYear;

      void changeDate(DateTime date) {
        if (date.year != moneyTxNotifier.currentDateTime.year) {
          moneyTxNotifier.fetchYearBalance(date);
        }
        moneyTxNotifier.changeDate(date);
        moneyTxNotifier.fetchMoneyTxs(date);
      }

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
                      changeDate: changeDate,
                    ),
                    Row(
                      children: [
                        MoneyInfoTile(
                            description: "Balanço do Mês",
                            value: getBalance(_moneyTxs)),
                      ],
                    ),
                    const Divider(),
                    chartFetchStatus == MoneyTxListStatus.loading
                        ? Skeletonizer(
                            containersColor: Colors.grey,
                            child: BalanceChart(
                            balance: fakeBalance,
                          ))
                        : BalanceChart(balance: yearBalance),
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
                      backgroundColor: WidgetStatePropertyAll(Theme.of(context).focusColor),
                      elevation: const WidgetStatePropertyAll(0),
                      hintText: 'Buscar',
                      leading: const Icon(Icons.search),
                      onChanged: (queryString) {
                        if (queryString.length > 3) {
                          moneyTxNotifier.fetchMoneyTxs(
                              currentDateTime, queryString);
                        } else {
                          moneyTxNotifier.fetchMoneyTxs(currentDateTime);
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

double getBalance(List<MoneyTx> moneyTxs) {
  return moneyTxs.fold(
      0, (sum, tx) => tx.isExpense ? sum - tx.value : sum + tx.value);
}

List<MonthBalance> getYearBalance(List<MoneyTx> moneyTxs) {
  final List<MonthBalance> balanceInYear = List<MonthBalance>.generate(
    12,
    (mb) => MonthBalance(income: 0, expenses: 0),
    growable: false,
  );

  for (MonthBalance balance in balanceInYear) {
    balance.income = 0;
    balance.expenses = 0;
  }

  for (MoneyTx tx in moneyTxs) {
    tx.isExpense
        ? balanceInYear[tx.date.month - 1].expenses += tx.value
        : balanceInYear[tx.date.month - 1].income += tx.value;
  }

  return balanceInYear;
}
