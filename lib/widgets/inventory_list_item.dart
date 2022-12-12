import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/business_logic/item_action.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/event_history_modal.dart';

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

  void showHistoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      builder: (_) => EventHistoryModal(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.read<UserRole>();

    final allActions = [EditItemAction(), DeleteItemAction(), ...actions];
    final allowedActions =
        allActions.where((action) => action.allowedRoles.contains(userRole));

    return ListTile(
      leading: Icon(itemTypes[item.type]),
      title: Text(item.id),
      subtitle: !showBorrower || item.borrower?.name == null
          ? null
          : Text(item.borrower!.name!),
      onTap:
          userRole == UserRole.admin ? () => showHistoryModal(context) : null,
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
  }
}
