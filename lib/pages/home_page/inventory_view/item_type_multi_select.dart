import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:spare_parts/utilities/constants.dart';

class ItemTypeMultiSelect extends StatelessWidget {
  final List<String>? value;
  final void Function(List<String>) onConfirm;
  const ItemTypeMultiSelect({
    super.key,
    required this.value,
    required this.onConfirm,
  });

  bool get isValueSet => value != null;

  @override
  Widget build(BuildContext context) {
    return MultiSelectDialogField<String>(
      chipDisplay: MultiSelectChipDisplay.none(),
      items: inventoryItems.entries
          .map((entry) => MultiSelectItem(entry.key, entry.key))
          .toList(),
      title: Text('Item Type'),
      buttonIcon: Icon(Icons.arrow_drop_down),
      selectedColor: Theme.of(context).primaryColor,
      decoration: BoxDecoration(
        borderRadius: kBorderRadius,
        color:
            isValueSet ? Theme.of(context).primaryColor.withOpacity(0.3) : null,
      ),
      buttonText: Text(
        'Item Type',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      onConfirm: onConfirm,
    );
  }
}
