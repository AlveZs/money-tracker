import 'package:flutter/material.dart';
import 'package:money_tracker/data/models/money/money_tx.dart';
import 'package:money_tracker/presentation/home/widgets/list_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TransactionsList extends StatelessWidget {
  final Future<List<MoneyTx>>? moneyTxsPromise;

  const TransactionsList({super.key, required this.moneyTxsPromise});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MoneyTx>>(
      future: moneyTxsPromise,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar as transações.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma transação encontrada.'));
          }
        }

        List<MoneyTx> moneyTxs =
            snapshot.connectionState == ConnectionState.waiting
                ? List.filled(
                    4,
                    MoneyTx(
                      'USER',
                      100,
                      DateTime.now(),
                    ))
                : snapshot.data!;

        return Skeletonizer(
          enabled: snapshot.connectionState == ConnectionState.waiting,
          containersColor: Colors.grey,
          child: TransactionListView(moneyTxs: moneyTxs),
        );
      },
    );
  }
}

class TransactionListView extends StatefulWidget {
  const TransactionListView({
    super.key,
    required this.moneyTxs,
  });

  final List<MoneyTx> moneyTxs;

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
                        setState(() {
                          widget.moneyTxs.removeAt(index);
                        });

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
