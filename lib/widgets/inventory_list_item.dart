import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/business_logic/item_action.dart';
import 'package:spare_parts/models/inventory_item.dart';
import 'package:spare_parts/utilities/constants.dart';

/// Represents an inventory item with actions
/// "edit" and "delete" actions are always available to the admin
/// optional actions can be supplied through the [actions] property
class InventoryListItem extends StatelessWidget {
  const InventoryListItem({
    Key? key,
    required this.item,
    this.actions = const [],
  }) : super(key: key);

  final InventoryItem item;
  final List<ItemAction> actions;

  @override
  Widget build(BuildContext context) {
    final userRole = context.read<UserRole>();

    final allActions = [EditItemAction(), DeleteItemAction(), ...actions];
    final allowedActions =
        allActions.where((action) => action.allowedRoles.contains(userRole));

    return ListTile(
      leading: Icon(inventoryItems[item.type]),
      title: Text(
        item.id,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 22),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => Container(
            child: Padding(
              padding: const EdgeInsets.all(100.0),
              child: Text('History'),
            ),
          ),
        );
      },
      trailing: PopupMenuButton<ItemAction>(
        child: Icon(Icons.more_vert),
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
  }
}
