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
  bool _approving = false;
  bool _denying = false;

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    final auth = context.watch<FirebaseAuth>();

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
              _approving ? CircularProgressIndicator() : Icon(Icons.check),
              SizedBox(width: 4),
              Text('Approve'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'deny',
          child: Row(
            children: [
              _denying ? CircularProgressIndicator() : Icon(Icons.close),
              SizedBox(width: 4),
              Text('Deny'),
            ],
          ),
        )
      ],
      onSelected: (value) async {
        if (_approving || _denying) return;

        if (value == 'approve') {
          setState(() {
            _approving = true;
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

            await firestoreService.approveBorrowingRequest(
              CustomUser.fromUser(auth.currentUser!),
              widget.borrowingRequest,
            );
          } catch (e) {
            print(e);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('An error occurred while approving the request'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ));
          } finally {
            setState(() {
              _approving = false;
            });
          }
        }
      },
    );
  }
}
