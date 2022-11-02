import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/inventory_view/item_type_filter_dialog.dart';

class ItemTypeMultiSelect extends StatelessWidget {
  final List<String>? selectedTypes;
  final void Function(List<String>) onConfirm;

  const ItemTypeMultiSelect({
    super.key,
    required this.selectedTypes,
    required this.onConfirm,
  });

  void _handleTypesSelect(BuildContext context) async {
    final newSelectedTypes = await showDialog<List<String>?>(
      context: context,
      builder: (context) =>
          ItemTypeFilterDialog(selectedTypes: selectedTypes ?? []),
    );

    if (newSelectedTypes != null) {
      onConfirm(newSelectedTypes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      label: Text('Item Types'),
      icon: Icon(Icons.filter_alt),
      style: TextButton.styleFrom(
        foregroundColor: selectedTypes == null
            ? Theme.of(context).textTheme.bodyText1!.color
            : null,
      ),
      onPressed: () => _handleTypesSelect(context),
    );
  }
}
