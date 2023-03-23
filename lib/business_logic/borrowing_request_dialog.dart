import 'package:flutter/material.dart';

class BorrowingRequestDialog extends StatelessWidget {
  const BorrowingRequestDialog({super.key});

  submitBorrowingRequest(context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Your borrowing request was submitted successfully. You will be notified when a decision is made.'),
    ));
  }

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
          onPressed: () => submitBorrowingRequest(context),
          child: Text('Submit request'),
        ),
      ],
    );
  }
}
