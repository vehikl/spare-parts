import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/item_page/item_page.dart';
import 'package:spare_parts/services/repositories/inventory_item_repository.dart';
import 'package:spare_parts/utilities/constants.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  late final ScaffoldMessengerState scaffoldMessenger;
  bool checkingCapture = false;

  @override
  void initState() {
    scaffoldMessenger = ScaffoldMessenger.of(context);
    super.initState();
  }

  void handleCapture(BarcodeCapture capture) async {
    if (checkingCapture) return;

    setState(() {
      checkingCapture = true;
    });

    final inventoryItemRepository = context.watch<InventoryItemRepository>();
    final userRole = context.watch<UserRole>();

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      try {
        final barcodeValue = barcodes.first.rawValue;

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
          scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Invalid QR Code: $barcodeValue'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        }
      } catch (e) {
        Navigator.pop(context);
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('An error occured while scanning QR Code'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      } finally {
        setState(() {
          checkingCapture = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: checkingCapture
          ? Center(child: CircularProgressIndicator())
          : MobileScanner(
              fit: BoxFit.contain,
              onDetect: (capture) => handleCapture(capture),
            ),
    );
  }
}
