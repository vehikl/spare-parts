import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/inventory_view_filter_selection.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/dialogs/value_selection_dialog.dart';
import 'package:spare_parts/widgets/inputs/multiselect_button.dart';

class ItemTypeFilter extends StatelessWidget {
  const ItemTypeFilter({
    super.key,
  });

  void onChanged(BuildContext context, List<String> selectedItemTypes) {
    final selection = context.read<InventoryViewFilterSelection>();
    selection.updateSelectedItemTypes(selectedItemTypes);
  }

  @override
  Widget build(BuildContext context) {
    final selectedItemTypes =
        context.select<InventoryViewFilterSelection, List<String>>(
            (selection) => selection.selectedItemTypes);

    return MultiselectButton<String>(
      buttonLabel: 'Item Types',
      hasSelection: selectedItemTypes.isNotEmpty,
      onConfirm: (values) => onChanged(context, values),
      dialog: ValueSelectionDialog<String>(
        values: itemTypes.keys.toList(),
        selectedValues: selectedItemTypes,
        title: 'Pick Item Types',
        leadingBuilder: (itemType) =>
            Icon(itemTypes[itemType] ?? itemTypes['Other']!),
      ),
    );
  }
}
