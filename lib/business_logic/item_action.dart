import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/event.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/callable_service.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/utilities/helpers.dart';
import 'package:spare_parts/widgets/inputs/value_selection_dialog.dart';
import 'package:spare_parts/widgets/inventory_item_form.dart';
import 'package:spare_parts/widgets/user_avatar.dart';

enum ItemActionType { delete, edit, borrow, release, assign }

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
      showError(
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

class AssignItemAction extends ItemAction {
  @override
  ItemActionType get actionType => ItemActionType.assign;

  @override
  IconData get icon => Icons.assignment;

  @override
  handle(BuildContext context, InventoryItem item) {
    final firestoreService = context.read<FirestoreService>();
    final callableService = context.read<CallableService>();

    commonHandle(
      () async {
        final users = await callableService.getUsers();

        final userId = await showDialog<String?>(
          context: context,
          builder: (context) => ValueSelectionDialog(
            isSingleSelection: true,
            title: 'Select user',
            values: users.map((u) => u.id).toList(),
            selectedValues: const [],
            labelBuilder: (uid) =>
                users.singleWhere((user) => user.id == uid).name,
            leadingBuilder: (uid) {
              final user = users.singleWhere((user) => user.id == uid);
              return UserAvatar(photoUrl: user.photoUrl);
            },
          ),
        );

        if (userId == null) return;

        item.borrower = users.firstWhere((u) => u.id == userId).toCustomUser();
        await firestoreService.updateItem(item.id, item);
      },
      context,
      'assigned',
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
        final user = auth.currentUser;
        if (user == null) return;

        final event = Event(
          issuerId: user.uid,
          issuerName: user.displayName ?? 'anonymous',
          type: 'Borrow',
          createdAt: DateTime.now(),
        );
        await firestoreService.addEvent(item.id, event);
        await firestoreService.borrowItem(
          item,
          CustomUser.fromUser(user),
        );
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
