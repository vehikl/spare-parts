import 'package:flutter/material.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/print_dialog/refreshable_title.dart';
import 'package:spare_parts/widgets/title_text.dart';
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
  bool printersRefreshing = false;
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
    await initAsync();
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

  Future<void> refreshPrinters() async {
    setState(() {
      printersRefreshing = true;
    });
    try {
      await initAsync();
      setState(() {
        printers = getPrinters();
      });
    } finally {
      setState(() {
        printersRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RefreshableTitle(
          onRefresh: refreshEnvironmentInfo,
          title: 'Environment Status',
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
        RefreshableTitle(
          onRefresh: refreshPrinters,
          title: 'Connected Printers',
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
