import 'package:flutter/material.dart';

class SelectionActions extends StatelessWidget {
  final void Function() onSelectAll;
  final void Function() onDeselectAll;
  final void Function() onPrintAll;

  const SelectionActions({
    Key? key,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onPrintAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(onPressed: onSelectAll, child: Text('Select All')),
        SizedBox(width: 8),
        TextButton(onPressed: onDeselectAll, child: Text('Deselect All')),
        Spacer(),
        ElevatedButton(onPressed: onPrintAll, child: Text('Print Labels')),
      ],
    );
  }
}
