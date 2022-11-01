import 'package:flutter/material.dart';
import 'package:spare_parts/utilities/constants.dart';

class ItemTypeMultiSelect extends StatelessWidget {
  final List<String>? value;
  final void Function(List<String>) onConfirm;
  const ItemTypeMultiSelect({
    super.key,
    required this.value,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: itemTypes.entries
          .map((entry) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  selected: value?.contains(entry.key) ?? false,
                  label: Icon(entry.value),
                  onSelected: (selected) {
                    final newValue = value ?? [];
                    if (newValue.contains(entry.key)) {
                      newValue.remove(entry.key);
                    } else {
                      newValue.add(entry.key);
                    }
                    onConfirm(newValue);
                  },
                ),
              ))
          .toList(),
    );
  }
}
