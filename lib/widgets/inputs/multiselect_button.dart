import 'package:flutter/material.dart';
import 'package:spare_parts/widgets/inputs/multiselect_dialog.dart';

class MultiselectButton extends StatelessWidget {
  final List<String> values;
  final List<String> selectedValues;
  final String buttonLabel;
  final void Function(List<String>) onConfirm;
  final IconData Function(String value)? iconBuilder;
  final String Function(String value)? labelBuilder;

  const MultiselectButton({
    super.key,
    required this.selectedValues,
    required this.onConfirm,
    required this.buttonLabel,
    required this.values,
    this.iconBuilder,
    this.labelBuilder,
  });

  void _handleChangeSelection(BuildContext context) async {
    final newSelectedValues = await showDialog<List<String>?>(
      context: context,
      builder: (context) => MultiselectDialog(
        title: 'Pick $buttonLabel',
        values: values,
        selectedValues: selectedValues,
        iconBuilder: iconBuilder,
        labelBuilder: labelBuilder
      ),
    );

    if (newSelectedValues != null) {
      onConfirm(newSelectedValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      label: Text(buttonLabel),
      icon: Icon(Icons.filter_alt),
      style: TextButton.styleFrom(
        foregroundColor: selectedValues.isEmpty
            ? Theme.of(context).textTheme.bodyText1!.color
            : null,
      ),
      onPressed: () => _handleChangeSelection(context),
    );
  }
}
