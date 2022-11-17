import 'package:flutter/material.dart';
import 'package:spare_parts/utilities/constants.dart';

class ValueSelectionDialog extends StatefulWidget {
  final List<String> selectedValues;
  final List<String> values;
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
  });

  @override
  State<ValueSelectionDialog> createState() => _ValueSelectionDialogState();
}

class _ValueSelectionDialogState extends State<ValueSelectionDialog> {
  late final List<String> _newSelectedValues;

  @override
  void initState() {
    _newSelectedValues = [...widget.selectedValues];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                children: widget.values
                    .map((value) => ListTile(
                          title: Text(widget.labelBuilder == null
                              ? value
                              : widget.labelBuilder!(value)),
                          leading: widget.leadingBuilder == null
                              ? null
                              : widget.leadingBuilder!(value),
                          selected: _newSelectedValues.contains(value),
                          selectedTileColor: kVehiklMaterialColor,
                          selectedColor: Colors.white,
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
            Navigator.pop(
              context,
              widget.isSingleSelection
                  ? _newSelectedValues.isEmpty
                      ? null
                      : _newSelectedValues.first
                  : _newSelectedValues,
            );
          },
          child: Text('Select'),
        )
      ],
    );
  }
}
