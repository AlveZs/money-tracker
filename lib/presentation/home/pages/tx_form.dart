import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_tracker/util/currency_input_formatter.dart';

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _txFormKey = GlobalKey<FormState>();
  TextEditingController dateCtl = TextEditingController();
  bool isExpense = false;

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: [
          SizedBox(height: 150, child: child),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Confirmar'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );

  final ButtonStyle cancelButtonStyle = TextButton.styleFrom(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _txFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Descrição',
            ),
          ),
          const SizedBox(height: 24),
          SegmentedButton<bool>(
            segments: const <ButtonSegment<bool>>[
              ButtonSegment<bool>(
                value: false,
                label: Text('Receita'),
                icon: Icon(Icons.arrow_upward),
              ),
              ButtonSegment<bool>(
                value: true,
                label: Text('Despesa'),
                icon: Icon(Icons.arrow_downward),
              ),
            ],
            selected: <bool>{isExpense},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() {
                isExpense = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Valor',
              prefixIcon: Icon(Icons.attach_money),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          TextFormField(
            readOnly: true,
            controller: dateCtl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Data',
              prefixIcon: Icon(Icons.calendar_month),
            ),
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());

              _showDialog(
                CupertinoDatePicker(
                  initialDateTime: DateTime.now(),
                  mode: CupertinoDatePickerMode.date,
                  maximumYear: DateTime.now().year,
                  minimumYear: DateTime.now().year - 100,
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    String day = '${newDate.day}'.padLeft(2, '0');
                    String month = '${newDate.month}'.padLeft(2, '0');
                    setState(
                        () => dateCtl.text = '$day/$month/${newDate.year}');
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: flatButtonStyle,
                  onPressed: () {},
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
