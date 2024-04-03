import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/item_page/item_page.dart';
import 'package:spare_parts/services/repositories/inventory_item_repository.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/utilities/helpers.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  bool _checkingCapture = false;

  void handleCapture(BarcodeCapture capture) async {
    if (_checkingCapture) return;

    setState(() {
      _checkingCapture = true;
    });

    final inventoryItemRepository = context.read<InventoryItemRepository>();
    final userRole = context.read<UserRole>();

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
          print('error');
          showError(
              context: context, message: 'Invalid QR code: $barcodeValue');
        }
      } catch (e) {
        showError(
            context: context,
            message: 'An error occured while scanning QR Code');
      } finally {
        setState(() {
          _checkingCapture = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: _checkingCapture
          ? Center(child: CircularProgressIndicator())
          : MobileScanner(
              fit: BoxFit.contain,
              onDetect: (capture) => handleCapture(capture),
              placeholderBuilder: (_, __) =>
                  Center(child: CircularProgressIndicator()),
              errorBuilder: (_, error, __) => Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    'Something went wrong while scanning: (${error.errorCode.name}) ${error.errorDetails?.message}',
                  ),
                ),
              ),
            ),
    );
  }
}
