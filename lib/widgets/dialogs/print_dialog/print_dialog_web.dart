library print_dialog_web;

import 'package:flutter/material.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/print_service.dart';
import 'package:spare_parts/widgets/buttons/cancel_button.dart';
import 'package:spare_parts/widgets/dialogs/print_dialog/print_dialog_body.dart';
import 'package:spare_parts/widgets/title_text.dart';

import '../../../services/dymo_service.dart';

class PrintDialog extends StatefulWidget {
  final List<InventoryItem> items;
  const PrintDialog({super.key, required this.items});

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

  void _handlePrintItems() {
    for (final item in widget.items) {
      PrintService.printQRCode(selectedPrinter!.name, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Print Label${widget.items.length > 1 ? 's' : ''}'),
      content: SizedBox(
        width: 400,
        child: FutureBuilder(
          future: initialization,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.items.length > 1)
                  TitleText('Printing labels for ${widget.items.length} items'),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 225),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: widget.items
                        .map((item) => Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                border: Border.all(color: Colors.white),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Property of Vehikl Inc.'),
                                    Icon(Icons.qr_code_2, size: 128),
                                    Text(item.nameForPrinting),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                PrintDialogBody(
                  selectedPrinter: selectedPrinter,
                  onPrinterSelected: (printer) => setState(() =>
                      selectedPrinter =
                          selectedPrinter == printer ? null : printer),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        CancelButton(),
        ElevatedButton(
          onPressed: selectedPrinter == null ? null : _handlePrintItems,
          child: const Text('Print'),
        ),
      ],
    );
  }
}
