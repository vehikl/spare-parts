import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/business_logic/item_action.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/pages/item_page.dart';

/// Represents an inventory item with actions
/// "edit" and "delete" actions are always available to the admin
/// optional actions can be supplied through the [actions] property
class InventoryListItem extends StatelessWidget {
  final bool showBorrower;

  const InventoryListItem({
    Key? key,
    required this.item,
    this.actions = const [],
    this.showBorrower = false,
  }) : super(key: key);

  final InventoryItem item;
  final List<ItemAction> actions;

  @override
  Widget build(BuildContext context) {
    final userRole = context.read<UserRole>();

    final allActions = [EditItemAction(), DeleteItemAction(), ...actions];
    final allowedActions =
        allActions.where((action) => action.allowedRoles.contains(userRole));

    return OpenContainer<bool>(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return ItemPage(item: item);
      },
      tappable: false,
      closedShape: const RoundedRectangleBorder(),
      closedElevation: 0.0,
      transitionDuration: Duration(milliseconds: 500),
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return ListTile(
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(itemTypes[item.type]),
              if (item.isPrivate)
                Positioned(
                  bottom: -3,
                  right: -5,
                  child: Icon(
                    Icons.visibility_off,
                    size: 13,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
          title: Text(item.name),
          subtitle: !showBorrower || item.borrower?.name == null
              ? null
              : Text(item.borrower!.name!),
          onTap: userRole == UserRole.admin ? openContainer : null,
          trailing: PopupMenuButton<ItemAction>(
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
          ),
        );
      },
    );
  }
}
