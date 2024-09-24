import 'package:flutter/material.dart';

class MoneyInfoTile extends StatelessWidget {
  final String description;
  final double value;

  const MoneyInfoTile({
    super.key,
    required this.description,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          Text(
            "R\$ ${(value).toStringAsFixed(2).replaceAll('.', ',')}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ],
      ),
    );
  }
}
