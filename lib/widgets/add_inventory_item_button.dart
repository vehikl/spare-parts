import 'package:flutter/material.dart';
import 'inventory_item_form.dart';

class AddInventoryItemButton extends StatelessWidget {
  const AddInventoryItemButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () async {
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return const InventoryItemForm(formState: InventoryFormState.add);
          },
        );
      },
    );
  }
}
