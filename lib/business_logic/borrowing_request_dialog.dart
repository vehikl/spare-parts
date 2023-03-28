import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/services/firestore_service.dart';

class BorrowingRequestDialog extends StatefulWidget {
  final String itemId;

  const BorrowingRequestDialog({super.key, required this.itemId});

  @override
  State<BorrowingRequestDialog> createState() => _BorrowingRequestDialogState();
}

class _BorrowingRequestDialogState extends State<BorrowingRequestDialog> {
  bool _isLoading = false;

  submitBorrowingRequest() async {
    FirestoreService firestoreService = context.read<FirestoreService>();
    FirebaseAuth auth = context.read<FirebaseAuth>();

    if (auth.currentUser?.uid == null) return;

    final borrowingRequest = BorrowingRequest(
      issuerId: auth.currentUser!.uid,
      itemId: widget.itemId,
    );
    setState(() {
      _isLoading = true;
    });
    await firestoreService.addBorrowingRequest(borrowingRequest);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Your borrowing request was submitted successfully. You will be notified when a decision is made.'),
    ));
    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Borrowing request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You have reached the maximum borrowing count for this item'),
          Text(
            'You can submit a borrowing request for this item. We will notify you when the decision is made.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: submitBorrowingRequest,
          child:
              _isLoading ? CircularProgressIndicator() : Text('Submit request'),
        ),
      ],
    );
  }
}
