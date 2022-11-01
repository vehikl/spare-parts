import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/inventory_view/item_type_filter_dialog.dart';

class ItemTypeMultiSelect extends StatelessWidget {
  final List<String>? value;
  final void Function(List<String>) onConfirm;

  const ItemTypeMultiSelect({
    super.key,
    required this.value,
    required this.onConfirm,
  });

  void _handleTypesSelect(BuildContext context) async {
    final newSelectedTypes = await showDialog<List<String>?>(
      context: context,
      builder: (context) => ItemTypeFilterDialog(selectedTypes: value ?? []),
    );

    if (newSelectedTypes != null) {
      onConfirm(newSelectedTypes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _handleTypesSelect(context),
      child: Text('Item Types'),
    );
  }
}
