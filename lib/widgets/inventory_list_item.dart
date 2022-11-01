import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/business_logic/item_action.dart';
import 'package:spare_parts/entities/event.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:intl/intl.dart';

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

  void showHistoryModal(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text('Interaction History', style: TextStyle(fontSize: 20)),
            StreamBuilder<List<Event>>(
              stream: firestoreService.getEventsStream(item.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorContainer(error: snapshot.error.toString());
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data!;

                if (events.isEmpty) {
                  return EmptyListState(
                      message: "This item was not borrowed yet...");
                }

                return ListView(
                  shrinkWrap: true,
                  children: events
                      .map((event) => ListTile(
                            title: Text(event.issuerName),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(event.type),
                                Text(
                                  event.createdAt == null
                                      ? 'N/A'
                                      : DateFormat.yMMMd()
                                          .format(event.createdAt!),
                                )
                              ],
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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
