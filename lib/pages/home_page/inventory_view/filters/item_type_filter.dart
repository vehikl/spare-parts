import 'package:flutter/material.dart';
import 'package:spare_parts/utilities/constants.dart';
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
    return MultiselectButton(
      buttonLabel: 'Item Types',
      values: itemTypes.keys.toList(),
      selectedValues: selectedItemTypes,
      icon: Icons.filter_list,
      leadingBuilder: (itemType) =>
          Icon(itemTypes[itemType] ?? itemTypes['Other']!),
      onConfirm: onChanged,
    );
  }
}
