import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/services/repositories/repositories.dart';

class BorrowingRequestDialog extends StatefulWidget {
  final InventoryItem item;
  final int maxBorrowingCount;

  const BorrowingRequestDialog({
    super.key,
    required this.item,
    required this.maxBorrowingCount,
  });

  @override
  State<BorrowingRequestDialog> createState() => _BorrowingRequestDialogState();
}

class _BorrowingRequestDialogState extends State<BorrowingRequestDialog> {
  bool _isLoading = false;

  submitBorrowingRequest() async {
    FirestoreService firestoreService = context.read<FirestoreService>();
    BorrowingRequestRepository borrowingRequestRepository = context.read<BorrowingRequestRepository>();
    FirebaseAuth auth = context.read<FirebaseAuth>();

    if (auth.currentUser?.uid == null) return;

    final borrowingRequest = BorrowingRequest(
      issuer: CustomUser.fromUser(auth.currentUser!),
      item: BorrowingRequestItem.fromInventoryItem(widget.item),
    );
    setState(() {
      _isLoading = true;
    });
    await borrowingRequestRepository.add(borrowingRequest);
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
          Text('You have reached the maximum borrowing count (${widget.maxBorrowingCount}) for this item'),
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
