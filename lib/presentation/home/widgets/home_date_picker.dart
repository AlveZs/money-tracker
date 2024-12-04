import 'package:flutter/material.dart';
import 'package:money_tracker/util/constants.dart';

import '../../../common/widgets/date_picker.dart';

class HomeDatePicker extends StatelessWidget {
  final DateTime date;
  final void Function(DateTime) changeDate;

  const HomeDatePicker({
    super.key,
    required this.date,
    required this.changeDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${monthsNames[date.month - 1]} de ${date.year.toString()}",
            style: const TextStyle(
              fontSize: 25,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomDatePicker(
              changeDate: changeDate,
            ),
          ),
        ],
      ),
    );
  }
}
