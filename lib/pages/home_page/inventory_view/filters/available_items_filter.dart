import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/inventory_view_filter_selection.dart';

class AvailableItemsFilter extends StatelessWidget {
  const AvailableItemsFilter({super.key});

  void onPressed(BuildContext context) {
    final selection = context.read<InventoryViewFilterSelection>();
    selection.toggleShowOnlyAvailableItems();
  }

  @override
  Widget build(BuildContext context) {
    final value = context.select<InventoryViewFilterSelection, bool>(
        (selection) => selection.showOnlyAvailableItems);

    return TextButton.icon(
      label: Text('Only available items'),
      icon: Icon(
        value ? Icons.check_box : Icons.check_box_outline_blank,
      ),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
      ),
      onPressed: () => onPressed(context),
    );
  }
}
