import 'package:flutter/material.dart';
import 'package:spare_parts/entities/inventory_item.dart';

class PrintDialog extends StatelessWidget {
  final List<InventoryItem> items;

  const PrintDialog({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Print Label'),
      content: const Text('Printing is only supported on the web'),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
