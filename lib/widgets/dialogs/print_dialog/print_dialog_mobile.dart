import 'package:flutter/material.dart';

class PrintDialog extends StatelessWidget {
  final String itemId;
  const PrintDialog({super.key, required this.itemId});

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
