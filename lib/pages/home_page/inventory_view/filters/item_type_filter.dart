import 'package:flutter/material.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/dialogs/value_selection_dialog.dart';
import 'package:spare_parts/widgets/inputs/multiselect_button.dart';

class ItemTypeFilter extends StatelessWidget {
  final List<String> selectedItemTypes;
  final Function(List<String>) onChanged;

  const ItemTypeFilter({
    super.key,
    required this.onChanged,
    required this.selectedItemTypes,
  });

  @override
  Widget build(BuildContext context) {
    return MultiselectButton<String>(
      buttonLabel: 'Item Types',
      hasSelection: selectedItemTypes.isNotEmpty,
      onConfirm: onChanged,
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
