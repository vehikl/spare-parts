import 'package:flutter/material.dart';

class SelectionActions extends StatelessWidget {
  const SelectionActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(onPressed: () {}, child: Text('Select All')),
        SizedBox(width: 8),
        TextButton(onPressed: () {}, child: Text('Deselect All')),
        Spacer(),
        ElevatedButton(onPressed: () {}, child: Text('Print Labels')),
      ],
    );
  }
}
