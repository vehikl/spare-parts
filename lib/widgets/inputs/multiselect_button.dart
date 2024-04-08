import 'package:flutter/material.dart';

class MultiselectButton<T> extends StatelessWidget {
  final bool hasSelection;
  final String buttonLabel;
  final void Function(List<T>) onConfirm;
  final Widget dialog;

  const MultiselectButton({
    super.key,
    required this.hasSelection,
    required this.onConfirm,
    required this.buttonLabel,
    required this.dialog,
  });

  void _handleChangeSelection(BuildContext context) async {
    final newSelectedValues = await showDialog<List<T>?>(
        context: context, builder: (context) => dialog);

    if (newSelectedValues != null) {
      onConfirm(newSelectedValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = TextButton.styleFrom(
      foregroundColor:
          hasSelection ? Theme.of(context).textTheme.bodyLarge!.color : null,
    );

    return TextButton.icon(
      label: Text(buttonLabel),
      icon: Icon(Icons.filter_list),
      style: buttonStyle,
      onPressed: () => _handleChangeSelection(context),
    );
  }
}
