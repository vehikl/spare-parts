import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/item_page/item_page.dart';
import 'package:spare_parts/services/repositories/inventory_item_repository.dart';
import 'package:spare_parts/utilities/constants.dart';

class QRScanPage extends StatelessWidget {
  const QRScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryItemRepository = context.watch<InventoryItemRepository>();
    final userRole = context.watch<UserRole>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner')),
      body: MobileScanner(
        fit: BoxFit.contain,
        onDetect: (capture) async {
          final List<Barcode> barcodes = capture.barcodes;

          if (barcodes.isNotEmpty) {
            try {
              final barcodeValue = barcodes.first.rawValue;
              print("IDDD: $barcodeValue");

              final itemRef = await inventoryItemRepository
                  .getItemDocumentReference(barcodeValue)
                  .get();

              if (itemRef.exists) {
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Provider.value(
                      value: userRole,
                      child: ItemPage(
                        itemId: itemRef.id,
                      ),
                    ),
                  ),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Invalid QR Code: $barcodeValue'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ));
              }
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('An error occured while scanning QR Code'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ));
            }
          }
        },
      ),
    );
  }
}
