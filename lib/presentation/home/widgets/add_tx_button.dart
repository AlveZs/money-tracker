import 'package:flutter/material.dart';
import 'package:money_tracker/presentation/home/pages/tx_form.dart';

class AddTxButton extends StatelessWidget {
  const AddTxButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: 450,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const TransactionForm(),
                      ElevatedButton(
                        child: const Text('Cancelar'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      icon: const Icon(
        Icons.add,
        color: Colors.black,
      ),
    );
  }
}
