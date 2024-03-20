import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/repositories/repositories.dart';
import 'package:spare_parts/utilities/constants.dart';

class BorrowingRequestActionsButton extends StatefulWidget {
  final BorrowingRequest borrowingRequest;
  const BorrowingRequestActionsButton({
    super.key,
    required this.borrowingRequest,
  });

  @override
  State<BorrowingRequestActionsButton> createState() =>
      _BorrowingRequestActionsButtonState();
}

class _BorrowingRequestActionsButtonState
    extends State<BorrowingRequestActionsButton> {
  bool _processing = false;

  void _handleSelection(value) async {
    final inventoryItemRepository = context.read<InventoryItemRepository>();
    final borrowingRequestRepository =
        context.read<BorrowingRequestRepository>();
    final auth = context.read<FirebaseAuth>();
    if (_processing) return;

    setState(() {
      _processing = true;
    });

    try {
      if (value == 'delete') {
        await borrowingRequestRepository.delete(widget.borrowingRequest.id);
      } else {
        final isApproved = value == 'approve';

        if (isApproved) {
          final requestedItemDoc = await inventoryItemRepository
              .getItemDocumentReference(widget.borrowingRequest.item.id)
              .get();
          final requestedItem = InventoryItem.fromFirestore(
            requestedItemDoc as DocumentSnapshot<Map<String, dynamic>>,
          );
          requestedItem.borrower = widget.borrowingRequest.issuer;
          await inventoryItemRepository.update(requestedItem);
        }

        await borrowingRequestRepository.makeDecision(
          decisionMaker: CustomUser.fromUser(auth.currentUser!),
          borrowingRequest: widget.borrowingRequest,
          isApproved: isApproved,
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('An error occurred while acting on the borrowing request'),
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
    final isAdmin = context.watch<UserRole>() == UserRole.admin;

    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        if (isAdmin)
          PopupMenuItem(
            value: 'approve',
            child: Row(
              children: [
                _processing
                    ? CircularProgressIndicator()
                    : Icon(Icons.check, color: Colors.green),
                SizedBox(width: 4),
                Text('Approve'),
              ],
            ),
          ),
        if (isAdmin)
          PopupMenuItem(
            value: 'deny',
            child: Row(
              children: [
                _processing
                    ? CircularProgressIndicator()
                    : Icon(Icons.close, color: Colors.red),
                SizedBox(width: 4),
                Text('Deny'),
              ],
            ),
          ),
        if (!isAdmin)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                _processing
                    ? CircularProgressIndicator()
                    : Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 4),
                Text('Delete'),
              ],
            ),
          )
      ],
      onSelected: _handleSelection,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Icon(Icons.more_vert),
      ),
    );
  }
}
