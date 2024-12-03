import 'package:flutter/material.dart';
import 'package:money_tracker/presentation/home/widgets/list_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../domain/entity/money_tx.dart';
import '../../provider/money_tx_provider.dart';

class TransactionsList extends StatelessWidget {
  final List<MoneyTx> moneyTxs;
  final MoneyTxListStatus txsFetchStatus;
  final Function(MoneyTx) deleteTransaction;

  const TransactionsList({
    super.key,
    required this.moneyTxs,
    required this.txsFetchStatus,
    required this.deleteTransaction,
  });

  @override
  Widget build(BuildContext context) {
    List<MoneyTx> moneyTxsList = txsFetchStatus == MoneyTxListStatus.loading
        ? List.filled(
            4,
            MoneyTx(
              description: 'USER',
              value: 100,
              date: DateTime.now(),
            ))
        : moneyTxs;

    if (txsFetchStatus == MoneyTxListStatus.failed) {
      return const Center(child: Text('Falha ao buscar os dados'));
    }

    return moneyTxs.isEmpty
        ? const Center(child: Text('Sem resultados'))
        : Skeletonizer(
            enabled: txsFetchStatus == MoneyTxListStatus.loading,
            containersColor: Colors.grey,
            child: TransactionListView(
              moneyTxs: moneyTxsList,
              deleteTransaction: deleteTransaction,
            ),
          );
  }
}

class TransactionListView extends StatefulWidget {
  const TransactionListView({
    super.key,
    required this.moneyTxs,
    required this.deleteTransaction,
  });

  final List<MoneyTx> moneyTxs;
  final Function(MoneyTx) deleteTransaction;

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.moneyTxs.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: Key("$index"),
          background: Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (DismissDirection direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Deletar"),
                  content:
                      const Text("Tem certeza que deseja deletar o pagamento?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCELAR"),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.deleteTransaction(widget.moneyTxs[index]);
                        Navigator.pop(context);
                      },
                      child: const Text("DELETAR"),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
            child: ListItem(
              description: widget.moneyTxs[index].description,
              value: widget.moneyTxs[index].value,
              date: widget.moneyTxs[index].date,
              isExpense: widget.moneyTxs[index].isExpense,
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
