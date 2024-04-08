import 'package:flutter/material.dart';
import 'package:spare_parts/utilities/helpers.dart';
import 'package:spare_parts/widgets/dialogs/value_selection_dialog.dart';

class MultiselectButton extends StatelessWidget {
  final List<String> values;
  final List<String> selectedValues;
  final String buttonLabel;
  final void Function(List<String>) onConfirm;
  final Widget Function(String value)? leadingBuilder;
  final String Function(String value) labelBuilder;
  final IconData? icon;

  const MultiselectButton({
    super.key,
    required this.selectedValues,
    required this.onConfirm,
    required this.buttonLabel,
    required this.values,
    this.labelBuilder = stringIdentity,
    this.leadingBuilder,
    this.icon,
  });

  void _handleChangeSelection(BuildContext context) async {
    final newSelectedValues = await showDialog<List<String>?>(
      context: context,
      builder: (context) => ValueSelectionDialog(
        title: 'Pick $buttonLabel',
        values: values,
        selectedValues: selectedValues,
        leadingBuilder: leadingBuilder,
        labelBuilder: labelBuilder,
      ),
    );

    if (newSelectedValues != null) {
      onConfirm(newSelectedValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = TextButton.styleFrom(
      foregroundColor: selectedValues.isEmpty
          ? Theme.of(context).textTheme.bodyLarge!.color
          : null,
    );
    if (icon == null) {
      return TextButton(
        style: buttonStyle,
        onPressed: () => _handleChangeSelection(context),
        child: Text(buttonLabel),
      );
    }

    return TextButton.icon(
      label: Text(buttonLabel),
      icon: Icon(icon),
      style: buttonStyle,
      onPressed: () => _handleChangeSelection(context),
    );
  }
}
