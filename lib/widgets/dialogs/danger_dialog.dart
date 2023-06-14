import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spare_parts/widgets/buttons/async_elevated_button.dart';
import 'package:spare_parts/widgets/buttons/cancel_button.dart';

class DangerDialog extends StatefulWidget {
  final String title;
  final String valueName;
  final String value;
  final AsyncCallback onConfirm;

  const DangerDialog({
    Key? key,
    required this.title,
    required this.valueName,
    required this.value,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<DangerDialog> createState() => _DangerDialogState();
}

class _DangerDialogState extends State<DangerDialog> {
  final TextEditingController _confirmController = TextEditingController();
  bool _confirmed = false;

  @override
  void initState() {
    _confirmController.addListener(() {
      var valueEnteredCorrectly = _confirmController.text == widget.value;
      if (_confirmed ^ valueEnteredCorrectly) {
        setState(() {
          _confirmed = valueEnteredCorrectly;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please enter the ${widget.valueName} (${widget.value}) to confirm'),
            TextField(controller: _confirmController),
          ],
        ),
      ),
      actions: [
        CancelButton(),
        AsyncElevatedButton(
          text: 'Confirm',
          onPressed: _confirmed
              ? () async {
                  await widget.onConfirm();
                  Navigator.pop(context, true);
                }
              : null,
        ),
      ],
    );
  }
}
