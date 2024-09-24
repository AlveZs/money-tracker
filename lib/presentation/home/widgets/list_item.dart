import 'package:flutter/material.dart';
import 'package:money_tracker/util/constants.dart';

class ListItem extends StatelessWidget {
  final String description;
  final double value;
  final DateTime date;
  final bool isExpense;

  const ListItem(
      {super.key,
      required this.description,
      required this.value,
      required this.date,
      this.isExpense = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: isExpense ? Colors.grey : const Color.fromARGB(255, 1, 47, 2),
          ),
          child: isExpense
              ? const Icon(
                  Icons.arrow_upward,
                )
              : const Icon(
                  Icons.arrow_downward,
                  color: Colors.green,
                ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isExpense ? 'Despesa' : 'Receita',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(description),
              Text('R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}'),
            ],
          ),
        ),
        Text(
            '${date.day} ${monthsNames[date.month - 1].toUpperCase().substring(0, 3)}'),
      ],
    );
  }
}
