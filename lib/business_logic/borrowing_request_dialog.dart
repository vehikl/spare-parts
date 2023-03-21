import 'package:flutter/material.dart';

class BorrowingRequestDialog extends StatelessWidget {
  const BorrowingRequestDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Borrowing request'),
      content:
          Text('You have reached the maximum borrowing count for this item'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Submit request'),
        ),
      ],
    );
  }
}
