import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/search_field.dart';

class ValueSelectionDialog extends StatefulWidget {
  final List<String> selectedValues;
  final List<String> values;
  final List<String> disabledValues;
  final String title;
  final bool isSingleSelection;
  final Widget Function(String value)? leadingBuilder;
  final String Function(String value)? labelBuilder;

  const ValueSelectionDialog({
    super.key,
    required this.selectedValues,
    required this.title,
    required this.values,
    this.isSingleSelection = false,
    this.leadingBuilder,
    this.labelBuilder,
    this.disabledValues = const [],
  });

  @override
  State<ValueSelectionDialog> createState() => _ValueSelectionDialogState();
}

class _ValueSelectionDialogState extends State<ValueSelectionDialog> {
  late final List<String> _allValues;
  late final List<String> _newSelectedValues;
  String _searchQuery = '';

  @override
  void initState() {
    _allValues = [...widget.values];
    _allValues.sort((value1, value2) => widget.labelBuilder == null
        ? value1.compareTo(value2)
        : widget.labelBuilder!(value1).compareTo(widget.labelBuilder!(value2)));
    _newSelectedValues = [...widget.selectedValues];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final filteredValues = _allValues.where((v) =>
        (widget.labelBuilder?.call(v) ?? v)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()));

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            TextButton(
              onPressed: () => setState(() {
                _newSelectedValues.clear();
              }),
              child: Text('Clear'),
            ),
            Divider(),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: filteredValues
                    .map((value) => Material(
                          child: ListTile(
                            title: Text(widget.labelBuilder == null
                                ? value
                                : widget.labelBuilder!(value)),
                            leading: widget.leadingBuilder == null
                                ? null
                                : widget.leadingBuilder!(value),
                            selected: _newSelectedValues.contains(value),
                            selectedTileColor:
                                Theme.of(context).colorScheme.primary,
                            selectedColor:
                                Theme.of(context).colorScheme.onPrimary,
                            enabled: !widget.disabledValues.contains(value),
                            onTap: () {
                              setState(() {
                                if (_newSelectedValues.contains(value)) {
                                  _newSelectedValues.remove(value);
                                } else {
                                  if (widget.isSingleSelection) {
                                    _newSelectedValues.clear();
                                  }
                                  _newSelectedValues.add(value);
                                }
                              });
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _newSelectedValues);
          },
          child: Text('Select'),
        )
      ],
    );
  }
}
