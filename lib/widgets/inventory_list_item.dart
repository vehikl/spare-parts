import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/models/inventory_item.dart';
import 'package:spare_parts/utilities/helpers.dart';
import 'package:spare_parts/widgets/inventory_item_form.dart';

class InventoryListItem extends StatelessWidget {
  const InventoryListItem({
    Key? key,
    required this.item,
    this.hasBorrowAction = false,
  }) : super(key: key);

  final InventoryItem item;
  final bool hasBorrowAction;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirebaseFirestore>();
    final userRole = context.read<UserRole>();
    final auth = context.read<FirebaseAuth>();

    return ListTile(
      leading: Icon(inventoryItems[item.type]),
      title: Text(
        item.id,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 22),
      ),
      trailing: PopupMenuButton<ItemAction>(
        child: Icon(Icons.more_vert),
        itemBuilder: (context) => [
          if (userRole == UserRole.admin)
            PopupMenuItem(
              value: ItemAction.edit,
              child: Row(
                children: const [
                  Icon(Icons.edit),
                  SizedBox(width: 4),
                  Text('Edit'),
                ],
              ),
            ),
          if (userRole == UserRole.admin)
            PopupMenuItem(
              value: ItemAction.delete,
              child: Row(
                children: [
                  Icon(Icons.delete, color: Theme.of(context).errorColor),
                  SizedBox(width: 4),
                  Text(
                    'Delete',
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                ],
              ),
            ),
          if (userRole == UserRole.user && hasBorrowAction)
            PopupMenuItem(
              value: ItemAction.borrow,
              child: Row(
                children: const [
                  Icon(Icons.delete),
                  SizedBox(width: 4),
                  Text('Borrow'),
                ],
              ),
            ),
        ],
        onSelected: (value) async {
          if (value == ItemAction.delete) {
            try {
              await firestore
                  .collection('items')
                  .doc(item.firestoreId)
                  .delete();
            } catch (e) {
              displayError(
                context: context,
                message: 'Error occured while deleting inventory item',
              );
            }
          }
          if (value == ItemAction.edit) {
            await showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return InventoryItemForm(
                  formState: InventoryFormState.edit,
                  item: item,
                );
              },
            );
          }
          if (value == ItemAction.borrow) {
            try {
              await firestore.collection('items').doc(item.firestoreId).update({
                'borrower': auth.currentUser?.uid,
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Item has been successfully borrowed')));
            } catch (e) {
              displayError(
                context: context,
                message: 'Error occured while borrowing inventory item',
              );
            }
          }
        },
      ),
    );
  }
}
