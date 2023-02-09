import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';

BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

class PrintDialog extends StatefulWidget {
  const PrintDialog({super.key});

  @override
  State<PrintDialog> createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog> {
  BluetoothDevice? _device;

  @override
  void initState() {
    bluetoothPrint.startScan(timeout: Duration(seconds: 10));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Print'),
      content: StreamBuilder<List<BluetoothDevice>>(
        stream: bluetoothPrint.scanResults,
        builder: (c, snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text('No devices found'),
            );
          }

          return Column(
            children: snapshot.data!
                .map((d) => ListTile(
                      title: Text(d.name ?? ''),
                      subtitle: d.address != null ? Text(d.address!) : null,
                      onTap: () async {
                        setState(() {
                          _device = d;
                        });
                      },
                      trailing: _device != null && _device?.address == d.address
                          ? Icon(
                              Icons.check,
                              color: Colors.green,
                            )
                          : null,
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
