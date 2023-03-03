import 'package:flutter/material.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';

import '../services/dymo_service.dart';

class PrintDialog extends StatefulWidget {
  final String itemId;
  const PrintDialog({super.key, required this.itemId});

  @override
  State<PrintDialog> createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog> {
  bool? isBrowserSupported;
  bool? isFrameworkInstalled;
  bool? isWebServicePresent;
  List<Printer> printers = [];
  Printer? selectedPrinter;

  @override
  void initState() {
    super.initState();
    init();
    printers = getPrinters();
    final status = checkEnvironment();
    isBrowserSupported = status.isBrowserSupported;
    isFrameworkInstalled = status.isFrameworkInstalled;
    isWebServicePresent = status.isWebServicePresent;
  }

  void refreshEnvironmentInfo() {
    init();
    final status = checkEnvironment();
    setState(() {
      isBrowserSupported = status.isBrowserSupported;
      isFrameworkInstalled = status.isFrameworkInstalled;
      isWebServicePresent = status.isWebServicePresent;
    });
  }

  void refreshPrinters() {
    init();
    setState(() {
      printers = getPrinters();
    });
  }

  Icon getStatusIcon(bool? status) {
    if (status == null) {
      return Icon(Icons.question_mark, color: Colors.grey);
    } else if (status == true) {
      return Icon(Icons.check, color: Colors.green);
    } else {
      return Icon(Icons.close, color: Colors.red);
    }
  }

  void printQRCode(String printerName) {
    final label = openLabelXml('''<?xml version="1.0" encoding="utf-8"?>
<DieCutLabel Version="8.0" Units="twips">
    <PaperOrientation>Landscape</PaperOrientation>
    <Id>NameBadgeTag</Id>
    <PaperName>30252 Address</PaperName>
    <ObjectInfo>
        <BarcodeObject>
            <Name>QRBarcode</Name>
            <ForeColor Alpha="255" Red="0" Green="0" Blue="0" />
            <BackColor Alpha="0" Red="255" Green="255" Blue="255" />
            <LinkedObjectName></LinkedObjectName>
            <Rotation>Rotation0</Rotation>
            <IsMirrored>False</IsMirrored>
            <IsVariable>False</IsVariable>
            <Text>${widget.itemId}</Text>
            <Type>QRCode</Type>
            <Size>Large</Size>
            <TextPosition>None</TextPosition>
            <TextFont Family="Arial" Size="8" Bold="False" Italic="False" Underline="False" Strikeout="False" />
            <CheckSumFont Family="Arial" Size="8" Bold="False" Italic="False" Underline="False" Strikeout="False" />
            <TextEmbedding>None</TextEmbedding>
            <ECLevel>0</ECLevel>
            <HorizontalAlignment>Center</HorizontalAlignment>
            <QuietZonesPadding Left="0" Top="0" Right="0" Bottom="0" />
        </BarcodeObject>
        <Bounds X="0" Y="0" Width="1600" Height="1600" />
    </ObjectInfo>
</DieCutLabel>''');
    label.print(printerName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Print Label'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Environment Status'),
          IconButton(
            onPressed: refreshEnvironmentInfo,
            icon: Icon(Icons.refresh),
          ),
          ListTile(
            leading: getStatusIcon(isBrowserSupported),
            title: Text('Browser Supported'),
          ),
          ListTile(
            leading: getStatusIcon(isFrameworkInstalled),
            title: Text('Framework Installed'),
          ),
          ListTile(
            leading: getStatusIcon(isWebServicePresent),
            title: Text('Web Service Present'),
          ),
          Text('Connected Printers'),
          IconButton(
            onPressed: refreshEnvironmentInfo,
            icon: Icon(Icons.refresh),
          ),
          if (printers.isEmpty)
            EmptyListState(message: 'No printers found')
          else
            ...printers.map(
              (printer) => ListTile(
                leading: Icon(selectedPrinter?.name == printer.name
                    ? Icons.check_box
                    : Icons.check_box_outline_blank),
                title: Text(printer.name),
                onTap: () {
                  setState(() {
                    selectedPrinter =
                        selectedPrinter?.name == printer.name ? null : printer;
                  });
                },
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedPrinter == null
              ? null
              : () => printQRCode(selectedPrinter!.name),
          child: const Text('Print'),
        ),
      ],
    );
  }
}
