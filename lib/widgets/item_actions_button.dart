import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/business_logic/item_action.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/utilities/constants.dart';

class ItemActionsButton extends StatelessWidget {
  final InventoryItem item;

  const ItemActionsButton({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final userRole = context.read<UserRole>();
    final auth = context.read<FirebaseAuth>();

    final allActions = [
      if (item.borrower == null)
        BorrowItemAction()
      else if (item.borrower?.uid == auth.currentUser?.uid)
        ReleaseItemAction(),
      EditItemAction(),
      DeleteItemAction(),
      AssignItemAction(),
      PrintAction()
    ];
    final allowedActions =
        allActions.where((action) => action.allowedRoles.contains(userRole));

    return PopupMenuButton<ItemAction>(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Icon(Icons.more_vert),
      ),
      itemBuilder: (context) => allowedActions.map((action) {
        return PopupMenuItem(
          value: action,
          child: Row(
            children: [
              Icon(action.icon),
              SizedBox(width: 4),
              Text(action.name),
            ],
          ),
        );
      }).toList(),
      onSelected: (itemAction) => itemAction.handle(context, item),
    );
  }
}
