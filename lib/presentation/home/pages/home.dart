import 'package:flutter/material.dart';
import 'package:money_tracker/balance_chart.dart';
import 'package:money_tracker/data/models/money/money_tx.dart';
import 'package:money_tracker/presentation/home/widgets/home_date_picker.dart';
import 'package:money_tracker/presentation/home/widgets/money_info_tile.dart';
import 'package:money_tracker/presentation/home/widgets/transactions_list.dart';
import 'package:money_tracker/util/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<MoneyTx>>? _moneyTxs;

  @override
  void initState() {
    _moneyTxs = getTransactions();
    super.initState();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _moneyTxs = getTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  HomeDatePicker(date: DateTime.now()),
                  const Row(
                    children: [
                      MoneyInfoTile(
                          description: "Balanço do Mês", value: 5000.10),
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
                collapsedHeight: 75,
                flexibleSpace: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const SearchBar(
                    hintText: 'Buscar',
                    leading: Icon(Icons.search),
                  ),
                ),
                backgroundColor: Theme.of(context).canvasColor,
                surfaceTintColor: Theme.of(context).canvasColor,
                pinned: true,
              ),
            ),
          ];
        },
        body: TransactionsList(moneyTxsPromise: _moneyTxs),
      ),
    );
  }
}
