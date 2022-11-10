import 'package:flutter/material.dart';

class AvailableItemsFilter extends StatelessWidget {
  final bool value;
  final void Function() onPressed;

  const AvailableItemsFilter({
    super.key,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      label: Text('Only available items'),
      icon: Icon(
        value ? Icons.check_box : Icons.check_box_outline_blank,
      ),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).textTheme.bodyText1!.color,
      ),
      onPressed: onPressed,
    );
  }
}
