import 'package:flutter/material.dart';
import 'package:spare_parts/utilities/helpers.dart';
import 'package:spare_parts/widgets/dialogs/dialog_width.dart';
import 'package:spare_parts/widgets/inputs/search_field.dart';

class ValueSelectionDialog<T> extends StatefulWidget {
  final List<T> selectedValues;
  final List<T> values;
  final List<T> disabledValues;
  final String title;
  final bool isSingleSelection;
  final Widget Function(T value)? leadingBuilder;
  final String Function(T value) labelBuilder;
  final Widget? trailing;

  const ValueSelectionDialog({
    super.key,
    required this.selectedValues,
    required this.title,
    required this.values,
    this.labelBuilder = stringIdentity,
    this.isSingleSelection = false,
    this.leadingBuilder,
    this.disabledValues = const [],
    this.trailing,
  });

  @override
  State<ValueSelectionDialog<T>> createState() =>
      _ValueSelectionDialogState<T>();
}

class _ValueSelectionDialogState<T> extends State<ValueSelectionDialog<T>> {
  late final List<T> _allValues;
  late final List<T> _newSelectedValues;
  String _searchQuery = '';

  @override
  void initState() {
    _allValues = [...widget.values];
    _allValues.sort((value1, value2) =>
        widget.labelBuilder(value1).compareTo(widget.labelBuilder(value2)));
    _newSelectedValues = [...widget.selectedValues];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final filteredValues = _allValues.where((v) => widget
        .labelBuilder(v)
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()));

    return AlertDialog(
      title: Text(widget.title),
      content: DialogWidth(
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
            SizedBox(height: 5),
            TextButton(
              onPressed: () => setState(() {
                _newSelectedValues.clear();
              }),
              child: Text('Clear Selection'),
            ),
            Divider(),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: filteredValues
                    .map((value) => Material(
                          child: ListTile(
                            title: Text(widget.labelBuilder(value)),
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
            if (widget.trailing != null) ...[
              SizedBox(height: 10),
              widget.trailing!,
            ]
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
