import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericFormField extends StatelessWidget {
  final int? initValue;
  final void Function(int?) onChanged;
  final String label;

  const NumericFormField({
    super.key,
    required this.initValue,
    required this.onChanged, required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initValue?.toString(),
      decoration: InputDecoration(label: Text(label)),
      onChanged: (String newValue) {
        final newNumericValue = newValue == "" ? null : int.parse(newValue);
        onChanged(newNumericValue);
      },
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (text) {
        if (text == null || text.isEmpty) return null;

        final number = int.tryParse(text);
        if (number == null) {
          return 'Please enter a valid number';
        }

        return null;
      },
    );
  }
}
