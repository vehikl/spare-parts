import 'package:flutter/material.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import '../../services/dymo_service.dart';

class PrintDialogBody extends StatefulWidget {
  final void Function(Printer) onPrinterSelected;
  final Printer? selectedPrinter;

  const PrintDialogBody({
    super.key,
    required this.onPrinterSelected,
    this.selectedPrinter,
  });

  @override
  State<PrintDialogBody> createState() => _PrintDialogBodyState();
}

class _PrintDialogBodyState extends State<PrintDialogBody> {
  bool? isBrowserSupported;
  bool? isFrameworkInstalled;
  bool? isWebServicePresent;
  List<Printer> printers = [];

  @override
  void initState() {
    super.initState();
    printers = getPrinters();
    final status = checkEnvironment();
    isBrowserSupported = status.isBrowserSupported;
    isFrameworkInstalled = status.isFrameworkInstalled;
    isWebServicePresent = status.isWebServicePresent;
  }

  Future<void> refreshEnvironmentInfo() async {
    // await initAsync();
    init();
    await Future.delayed(const Duration(seconds: 2));
    final status = checkEnvironment();
    setState(() {
      isBrowserSupported = status.isBrowserSupported;
      isFrameworkInstalled = status.isFrameworkInstalled;
      isWebServicePresent = status.isWebServicePresent;
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

  void refreshPrinters() async {
    init();
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      printers = getPrinters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              leading: Icon(widget.selectedPrinter?.name == printer.name
                  ? Icons.check_box
                  : Icons.check_box_outline_blank),
              title: Text(printer.name),
              onTap: () => widget.onPrinterSelected(printer),
            ),
          ),
      ],
    );
  }
}
