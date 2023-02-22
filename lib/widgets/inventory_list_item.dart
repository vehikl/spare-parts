import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/item_page.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/item_actions_button.dart';
import 'package:spare_parts/widgets/item_icon.dart';

/// Represents an inventory list item with actions
class InventoryListItem extends StatelessWidget {
  final bool showBorrower;
  final InventoryItem item;

  const InventoryListItem({
    Key? key,
    required this.item,
    this.showBorrower = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRole = context.read<UserRole>();

    return OpenContainer<bool>(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return Provider.value(value: userRole, child: ItemPage(item: item));
      },
      tappable: false,
      closedShape: const RoundedRectangleBorder(),
      closedElevation: 0.0,
      transitionDuration: Duration(milliseconds: 500),
      closedColor: Theme.of(context).colorScheme.background,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return ListTile(
          leading: ItemIcon(item: item),
          title: Text(item.name),
          subtitle: !showBorrower || item.borrower?.name == null
              ? null
              : Text(item.borrower!.name!),
          onTap: userRole == UserRole.admin ? openContainer : null,
          trailing: ItemActionsButton(item: item),
        );
      },
    );
  }
}
