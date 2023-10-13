library print_dialog_web;

import 'package:flutter/material.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/print_service.dart';
import 'package:spare_parts/widgets/dialogs/print_dialog/print_dialog_body.dart';

import '../../../services/dymo_service.dart';

class PrintDialog extends StatefulWidget {
  final InventoryItem item;
  const PrintDialog({super.key, required this.item});

  @override
  State<PrintDialog> createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog> {
  Printer? selectedPrinter;
  late Future<void> initialization;

  @override
  void initState() {
    super.initState();
    initialization = initAsync();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Print Label'),
      content: FutureBuilder(
        future: initialization,
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                  ],
                )
              : PrintDialogBody(
                  selectedPrinter: selectedPrinter,
                  onPrinterSelected: (printer) => setState(() =>
                      selectedPrinter =
                          selectedPrinter == printer ? null : printer),
                );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedPrinter == null
              ? null
              : () => PrintService.printQRCode(
                    selectedPrinter!.name,
                    widget.item,
                  ),
          child: const Text('Print'),
        ),
      ],
    );
  }
}
