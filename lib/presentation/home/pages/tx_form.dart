import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_tracker/domain/entity/money_tx.dart';
import 'package:money_tracker/presentation/provider/money_tx_provider.dart';
import 'package:money_tracker/util/currency_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _txFormKey = GlobalKey<FormState>();
  final TextEditingController _dateCtl = TextEditingController();
  final TextEditingController _descriptionCtl = TextEditingController();
  final TextEditingController _valueCtl = TextEditingController();
  bool isExpense = false;

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: [
          SizedBox(height: 170, child: child),
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
    return Consumer<MoneyTxProvider>(
        builder: (context, moneyTxNotifier, child) {
      return Form(
        key: _txFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a descrição';
                }

                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Descrição',
              ),
              controller: _descriptionCtl,
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o valor da transação';
                }

                return null;
              },
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
              controller: _valueCtl,
            ),
            const SizedBox(height: 24),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a data da transação';
                }

                return null;
              },
              readOnly: true,
              controller: _dateCtl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Data',
                prefixIcon: Icon(Icons.calendar_month),
              ),
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                if (_dateCtl.text == '') {
                  String formattedDate = getFormattedDate(DateTime.now());
                  setState(() => _dateCtl.text = formattedDate);
                }
                _showDialog(
                  CupertinoDatePicker(
                    initialDateTime: _dateCtl.text != ''
                        ? getDateTimeFromString(_dateCtl.text)
                        : DateTime.now(),
                    mode: CupertinoDatePickerMode.date,
                    maximumYear: DateTime.now().year,
                    minimumYear: DateTime.now().year - 100,
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime newDate) {
                      String formattedDate = getFormattedDate(newDate);
                      setState(() => _dateCtl.text = formattedDate);
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
                    onPressed: () {
                      if (_txFormKey.currentState!.validate()) {
                        addTx(moneyTxNotifier).then((result) {
                          result
                              ? ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Transação salva com sucesso!'),
                                  ),
                                )
                              : ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    content:
                                        const Text('Erro ao salvar a transação!'),
                                  ),
                                );
                        }).onError((e, _) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              content: const Text('Erro ao salvar a transação!'),
                            ),
                          );
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  String getFormattedDate(DateTime date) {
    String day = '${date.day}'.padLeft(2, '0');
    String month = '${date.month}'.padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  DateTime getDateTimeFromString(String date) {
    List<String> dateString = _dateCtl.text.split('/');
    String formattedDateString =
        '${dateString[2]}-${dateString[1]}-${dateString[0]}';

    return DateTime.parse(formattedDateString);
  }

  Future<bool> addTx(MoneyTxProvider txNotifier) async {
    MoneyTx data = MoneyTx(
      id: const Uuid().v4(),
      value: double.parse(_valueCtl.text
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .replaceAll(RegExp(r'[^0-9!.]'), '')),
      date: getDateTimeFromString(_dateCtl.text),
      description: _descriptionCtl.text,
      isExpense: isExpense,
    );

    return await txNotifier.createMoneyTx(data);
  }
}
