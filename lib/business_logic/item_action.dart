import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/event.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/utilities/helpers.dart';
import 'package:spare_parts/widgets/inventory_item_form.dart';

enum ItemActionType { delete, edit, borrow, release }

abstract class ItemAction {
  ItemActionType get actionType;
  IconData get icon;
  List<UserRole> get allowedRoles;

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
      log(e.toString());
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
      () => firestoreService.deleteItem(item.id),
      context,
      'deleted',
    );
  }

  @override
  List<UserRole> get allowedRoles => [UserRole.admin];
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
      () async {
        final event = Event(
            issuerId: auth.currentUser?.uid ?? '',
            issuerName: auth.currentUser?.displayName ?? '',
            type: 'Borrow',
            createdAt: DateTime.now());
        await firestoreService.addEvent(item.id, event);
        await firestoreService.borrowItem(item, auth.currentUser?.uid);
      },
      context,
      'borrowed',
    );
  }

  @override
  List<UserRole> get allowedRoles => [UserRole.admin, UserRole.user];
}

class ReleaseItemAction extends ItemAction {
  @override
  ItemActionType get actionType => ItemActionType.release;

  @override
  IconData get icon => Icons.arrow_upward;

  @override
  handle(BuildContext context, InventoryItem item) {
    final firestoreService = context.read<FirestoreService>();
    final auth = context.read<FirebaseAuth>();

    commonHandle(
      () async {
        final event = Event(
          issuerId: auth.currentUser?.uid ?? '',
          issuerName: auth.currentUser?.displayName ?? '',
          type: 'Release',
          createdAt: DateTime.now(),
        );
        await firestoreService.addEvent(item.id, event);
        await firestoreService.releaseItem(item);
      },
      context,
      'released',
    );
  }

  @override
  List<UserRole> get allowedRoles => [UserRole.admin, UserRole.user];
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

  @override
  List<UserRole> get allowedRoles => [UserRole.admin];
}
