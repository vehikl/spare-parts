import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/business_logic/borrowing_request_dialog.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/utilities/helpers.dart';
import 'package:spare_parts/widgets/dialogs/print_dialog/print_dialog_mobile.dart'
    if (dart.library.html) 'package:spare_parts/widgets/dialogs/print_dialog/print_dialog_web.dart';
import 'package:spare_parts/widgets/inputs/user_selection_dialog.dart';
import 'package:spare_parts/widgets/inventory_list_item/inventory_item_form.dart';

import '../services/repositories/repositories.dart';

enum ItemActionType { delete, edit, borrow, release, assign, print }

abstract class ItemAction {
  ItemActionType get actionType;
  IconData get icon;
  List<UserRole> get allowedRoles => [];

  bool isVisibleForUser(InventoryItem item, String uid, UserRole role) {
    return allowedRoles.contains(role);
  }

  handle(BuildContext context, InventoryItem item);

  String get name {
    final lowerCaseName = actionType.toString().split('.')[1];
    return lowerCaseName[0].toUpperCase() + lowerCaseName.substring(1);
  }

  void commonHandle(
    FutureOr<bool> Function() action,
    BuildContext context,
    String message,
  ) async {
    try {
      final showSuccess = await action();
      if (showSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Item has been successfully $message'),
        ));
      }
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
    final inventoryItemRepository = context.read<InventoryItemRepository>();

    commonHandle(
      () async {
        await inventoryItemRepository.delete(item.id);
        return true;
      },
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
    final inventoryItemRepository = context.read<InventoryItemRepository>();

    commonHandle(
      () async {
        final users = await showDialog<List<CustomUser>?>(
          context: context,
          builder: (context) => UserSelectionDialog(
            title: 'Select user',
            isSingleSelection: true,
            selectedUsers: item.borrower == null ? [] : [item.borrower!],
          ),
        );

        if (users == null) return false;

        item.borrower = users.firstOrNull;
        await inventoryItemRepository.update(item);
        return true;
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
    final inventoryItemRepository = context.read<InventoryItemRepository>();
    final borrowingRuleRepository = context.read<BorrowingRuleRepository>();
    final eventRepository = context.read<EventRepository>();
    final borrowingRequestRepository =
        context.read<BorrowingRequestRepository>();
    final auth = context.read<FirebaseAuth>();

    commonHandle(
      () async {
        final user = auth.currentUser;
        if (user == null) return false;

        final borrowingRule =
            await borrowingRuleRepository.getForItemType(item.type);

        if (borrowingRule != null) {
          final borrowingCount =
              await borrowingRuleRepository.getBorrowingCount(
            item.type,
            auth.currentUser!.uid,
          );

          if (borrowingCount >= borrowingRule.maxBorrowingCount) {
            final pendingBorrowingRequest = await borrowingRequestRepository
                .getPendingForInventoryItem(item.id);
            if (pendingBorrowingRequest != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('You have already requested this item'),
              ));
              return false;
            }

            showDialog(
              context: context,
              builder: (context) => BorrowingRequestDialog(
                item: item,
                maxBorrowingCount: borrowingRule.maxBorrowingCount,
              ),
            );
            return false;
          }
        }

        await inventoryItemRepository.borrow(
          item,
          CustomUser.fromUser(user),
        );

        await eventRepository.add(item.id, eventType: 'Borrow');

        return true;
      },
      context,
      'borrowed',
    );
  }

  @override
  List<UserRole> get allowedRoles => [UserRole.admin, UserRole.user];

  @override
  bool isVisibleForUser(InventoryItem item, String uid, UserRole role) {
    return item.borrower == null;
  }
}

class ReleaseItemAction extends ItemAction {
  @override
  ItemActionType get actionType => ItemActionType.release;

  @override
  IconData get icon => Icons.arrow_upward;

  @override
  handle(BuildContext context, InventoryItem item) {
    final eventRepository = context.read<EventRepository>();
    final inventoryItemRepository = context.read<InventoryItemRepository>();

    commonHandle(
      () async {
        await eventRepository.add(item.id, eventType: 'Release');
        await inventoryItemRepository.release(item);

        return true;
      },
      context,
      'released',
    );
  }

  @override
  List<UserRole> get allowedRoles => [UserRole.admin, UserRole.user];

  @override
  bool isVisibleForUser(InventoryItem item, String uid, UserRole role) {
    if (role == UserRole.admin) return true;

    return item.borrower?.uid == uid;
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

  @override
  List<UserRole> get allowedRoles => [UserRole.admin];
}

class PrintAction extends ItemAction {
  @override
  ItemActionType get actionType => ItemActionType.print;

  @override
  IconData get icon => Icons.print;

  @override
  handle(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => PrintDialog(item: item),
    );
  }

  @override
  List<UserRole> get allowedRoles => [UserRole.admin];
}
