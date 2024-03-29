import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/item_page/item_page.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inventory_list_item/item_actions_button.dart';
import 'package:spare_parts/widgets/item_icon.dart';

/// Represents an inventory list item with actions
class InventoryListItem extends StatelessWidget {
  final bool showBorrower;
  final InventoryItem item;
  final bool selectable;
  final bool selected;
  final void Function(String itemId)? onSelected;

  const InventoryListItem({
    Key? key,
    required this.item,
    this.showBorrower = false,
    this.selectable = false,
    this.selected = false,
    this.onSelected,
  }) : super(key: key);

  void _handleLongPress(BuildContext context, InventoryItem item) {
    final isAdmin = context.read<UserRole>() == UserRole.admin;
    if (!isAdmin) return;

    onSelected?.call(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.read<UserRole>();

    return OpenContainer<bool>(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return Provider.value(
          value: userRole,
          child: ItemPage(itemId: item.id),
        );
      },
      tappable: false,
      closedShape: const RoundedRectangleBorder(),
      closedElevation: 0.0,
      transitionDuration: Duration(milliseconds: 500),
      closedColor: Theme.of(context).colorScheme.background,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return Provider.value(
          value: userRole,
          child: ListTile(
            onLongPress: () => _handleLongPress(context, item),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectable) ...[
                  if (selected)
                    Icon(Icons.check_box)
                  else
                    Icon(Icons.check_box_outline_blank),
                  SizedBox(width: 8),
                ],
                ItemIcon(item: item),
              ],
            ),
            title: Text(item.name),
            subtitle: !showBorrower || item.borrower?.name == null
                ? null
                : Text(item.borrower!.name!),
            onTap: selectable ? () => onSelected!(item.id) : openContainer,
            trailing: ItemActionsButton(item: item),
          ),
        );
      },
    );
  }
}
