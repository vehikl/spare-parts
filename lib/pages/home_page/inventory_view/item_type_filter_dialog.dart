import 'package:flutter/material.dart';
import 'package:spare_parts/utilities/constants.dart';

class ItemTypeFilterDialog extends StatefulWidget {
  final List<String> selectedTypes;

  const ItemTypeFilterDialog({super.key, required this.selectedTypes});

  @override
  State<ItemTypeFilterDialog> createState() => _ItemTypeFilterDialogState();
}

class _ItemTypeFilterDialogState extends State<ItemTypeFilterDialog> {
  late final List<String> _newSelectedTypes;

  @override
  void initState() {
    _newSelectedTypes = widget.selectedTypes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter by item type'),
      content: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () => setState(() {
                _newSelectedTypes.clear();
              }),
              child: Text('Clear'),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: itemTypes.entries
                    .map((itemType) => ListTile(
                          title: Text(itemType.key),
                          leading: Icon(itemType.value),
                          selected: widget.selectedTypes.contains(itemType.key),
                          selectedTileColor: kVehiklMaterialColor,
                          selectedColor: Colors.white,
                          onTap: () {
                            setState(() {
                              if (_newSelectedTypes.contains(itemType.key)) {
                                _newSelectedTypes.remove(itemType.key);
                              } else {
                                _newSelectedTypes.add(itemType.key);
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
            Navigator.pop(context, _newSelectedTypes);
          },
          child: Text('Filter'),
        )
      ],
    );
  }
}
