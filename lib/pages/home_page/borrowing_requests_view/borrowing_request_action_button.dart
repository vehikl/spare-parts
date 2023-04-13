import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';

class BorrowingRequestActionsButton extends StatefulWidget {
  final BorrowingRequest borrowingRequest;
  const BorrowingRequestActionsButton(
      {super.key, required this.borrowingRequest});

  @override
  State<BorrowingRequestActionsButton> createState() =>
      _BorrowingRequestActionsButtonState();
}

class _BorrowingRequestActionsButtonState
    extends State<BorrowingRequestActionsButton> {
  bool _processing = false;

  void _handleSelection(value) async {
    final firestoreService = context.watch<FirestoreService>();
    final auth = context.watch<FirebaseAuth>();
    if (_processing) return;

    setState(() {
      _processing = true;
    });
    try {
      final requestedItemDoc = await firestoreService
          .getItemDocumentReference(widget.borrowingRequest.item.id)
          .get();
      final requestedItem = InventoryItem.fromFirestore(
        requestedItemDoc as DocumentSnapshot<Map<String, dynamic>>,
      );
      requestedItem.borrower = widget.borrowingRequest.issuer;
      await firestoreService.updateItem(requestedItem.id, requestedItem);

      await firestoreService.makeDecisionOnBorrowingRequest(
          decisionMaker: CustomUser.fromUser(auth.currentUser!),
          borrowingRequest: widget.borrowingRequest,
          isApproved: value == 'approve');
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred while approving the request'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Icon(Icons.more_vert),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'approve',
          child: Row(
            children: [
              _processing ? CircularProgressIndicator() : Icon(Icons.check),
              SizedBox(width: 4),
              Text('Approve'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'deny',
          child: Row(
            children: [
              _processing ? CircularProgressIndicator() : Icon(Icons.close),
              SizedBox(width: 4),
              Text('Deny'),
            ],
          ),
        )
      ],
      onSelected: _handleSelection,
    );
  }
}
