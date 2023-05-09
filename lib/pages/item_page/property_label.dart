import 'package:flutter/material.dart';

class ItemPropertyText extends StatelessWidget {
  final String label;
  final String text;

  const ItemPropertyText(this.text, {super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label:', style: TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }
}
