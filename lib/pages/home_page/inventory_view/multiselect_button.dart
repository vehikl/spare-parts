import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/inventory_view/multiselect_dialog.dart';
import 'package:spare_parts/utilities/constants.dart';

class MultiselectButton extends StatelessWidget {
  final List<String> values;
  final List<String> selectedValues;
  final String label;
  final void Function(List<String>) onConfirm;
  final IconData Function(String value)? iconBuilder;

  const MultiselectButton({
    super.key,
    required this.selectedValues,
    required this.onConfirm,
    required this.label,
    required this.values,
    this.iconBuilder,
  });

  void _handleChangeSelection(BuildContext context) async {
    final newSelectedValues = await showDialog<List<String>?>(
      context: context,
      builder: (context) => MultiselectDialog(
        values: values,
        selectedValues: selectedValues,
        iconBuilder: iconBuilder,
        title: 'Pick $label',
      ),
    );

    if (newSelectedValues != null) {
      onConfirm(newSelectedValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      label: Text(label),
      icon: Icon(Icons.filter_alt),
      style: TextButton.styleFrom(
        foregroundColor: selectedValues.isEmpty
            ? Theme.of(context).textTheme.bodyText1!.color
            : null,
        shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
      ),
      onPressed: () => _handleChangeSelection(context),
    );
  }
}
