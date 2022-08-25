import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/models/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/helpers.dart';
import 'package:spare_parts/widgets/inventory_item_form.dart';

enum ItemActionType { delete, edit, borrow, release }

abstract class ItemAction {
  ItemActionType get actionType;
  IconData get icon;

  handle(BuildContext context, InventoryItem item);

  String get name {
    final lowerCaseName = actionType.toString().split('.')[1];
    return lowerCaseName[0].toUpperCase() + lowerCaseName.substring(1);
  }

  void commonHandle(
    Function action,
    BuildContext context,
    String message,
  ) async {
    try {
      await action();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Item has been successfully $message'),
      ));
    } catch (e) {
      displayError(
        context: context,
        message: 'Error occured: inventory item was not $message',
      );
    }
  }
}

class DeleteItemAction extends ItemAction {
  @override
  ItemActionType get actionType => ItemActionType.delete;

  @override
  IconData get icon => Icons.delete;

  @override
  handle(BuildContext context, InventoryItem item) {
    final firestoreService = context.read<FirestoreService>();

    commonHandle(
      () => firestoreService.deleteItem(item.firestoreId),
      context,
      'deleted',
    );
  }
}

class BorrowItemAction extends ItemAction {
  @override
  ItemActionType get actionType => ItemActionType.borrow;

  @override
  IconData get icon => Icons.arrow_downward;

  @override
  handle(BuildContext context, InventoryItem item) {
    final firestoreService = context.read<FirestoreService>();
    final auth = context.read<FirebaseAuth>();

    commonHandle(
      () => firestoreService.borrowItem(item, auth.currentUser?.uid),
      context,
      'borrowed',
    );
  }
}

class ReleaseItemAction extends ItemAction {
  @override
  ItemActionType get actionType => ItemActionType.release;

  @override
  IconData get icon => Icons.arrow_upward;

  @override
  handle(BuildContext context, InventoryItem item) {
    final firestoreService = context.read<FirestoreService>();

    commonHandle(
      () => firestoreService.releaseItem(item),
      context,
      'released',
    );
  }
}

class EditItemAction extends ItemAction {
  @override
  ItemActionType get actionType => ItemActionType.edit;

  @override
  IconData get icon => Icons.edit;

  @override
  handle(BuildContext context, InventoryItem item) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return InventoryItemForm(
          formState: InventoryFormState.edit,
          item: item,
        );
      },
    );
  }
}
