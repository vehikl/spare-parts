import 'package:flutter/material.dart';
import 'package:spare_parts/utilities/constants.dart';

class MultiselectDialog extends StatefulWidget {
  final List<String> selectedValues;
  final List<String> values;
  final String title;
  final IconData Function(String value)? iconBuilder;

  const MultiselectDialog({
    super.key,
    required this.selectedValues,
    required this.title,
    required this.values,
    this.iconBuilder,
  });

  @override
  State<MultiselectDialog> createState() => _MultiselectDialogState();
}

class _MultiselectDialogState extends State<MultiselectDialog> {
  late final List<String> _newSelectedValues;

  @override
  void initState() {
    _newSelectedValues = widget.selectedValues;
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
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: widget.values
                    .map((value) => ListTile(
                          title: Text(value),
                          leading: widget.iconBuilder == null
                              ? null
                              : Icon(widget.iconBuilder!(value)),
                          selected: widget.selectedValues.contains(value),
                          selectedTileColor: kVehiklMaterialColor,
                          selectedColor: Colors.white,
                          onTap: () {
                            setState(() {
                              if (_newSelectedValues.contains(value)) {
                                _newSelectedValues.remove(value);
                              } else {
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
            Navigator.pop(context, _newSelectedValues);
          },
          child: Text('Select'),
        )
      ],
    );
  }
}
