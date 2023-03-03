import 'package:flutter/material.dart';

class PrintDialog extends StatefulWidget {
  const PrintDialog({super.key});

  @override
  State<PrintDialog> createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Print Label'),
      content: const Placeholder(),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Print'),
        ),
      ],
    );
  }
}