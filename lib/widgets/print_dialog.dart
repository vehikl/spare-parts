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
  bool _connected = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
    super.initState();
  }

  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bluetoothPrint.state.listen((state) {
      print('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Print'),
      content: StreamBuilder<List<BluetoothDevice>>(
        stream: bluetoothPrint.scanResults,
        builder: (c, snapshot) {
          if (snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return Center(child: Text('No devices found'));
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: snapshot.data!
                    .map((d) => ListTile(
                          title: Text(d.name ?? ''),
                          onTap: () async {
                            setState(() {
                              _device = d;
                            });
                          },
                          trailing:
                              _device != null && _device?.address == d.address
                                  ? Icon(Icons.check, color: Colors.green)
                                  : null,
                        ))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: () async {
                  await bluetoothPrint.connect(_device!);
                },
                child: Text('Connect'),
              ),
              ElevatedButton(
                onPressed: _connected
                    ? () async {
                        Map<String, dynamic> config = {
                          'width': 30,
                          'height': 15,
                        };
                        List<LineText> list = [];
                        list.add(LineText(
                          type: LineText.TYPE_TEXT,
                          x: 0,
                          y: 0,
                          content: 'A Title',
                        ));

                        await bluetoothPrint.printLabel(config, list);
                      }
                    : null,
                child: Text('Print'),
              ),
            ],
          );
        },
      ),
    );
  }
}
