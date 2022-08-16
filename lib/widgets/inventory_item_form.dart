import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/models/inventory_item.dart';
import 'package:spare_parts/utilities/helpers.dart';

enum InventoryFormState { edit, add }

class InventoryItemForm extends StatefulWidget {
  final InventoryFormState formState;
  final InventoryItem? item;

  const InventoryItemForm({Key? key, required this.formState, this.item})
      : super(key: key);

  @override
  State<InventoryItemForm> createState() => _InventoryItemFormState();
}

class _InventoryItemFormState extends State<InventoryItemForm> {
  final _formKey = GlobalKey<FormState>();
  String dropdownValue = inventoryItems.keys.first;
  String idValue = '';

  @override
  void initState() {
    final item = widget.item;
    if (item != null) {
      idValue = item.id;
      dropdownValue = item.type;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirebaseFirestore>();
    final firestoreService = context.read<FirestoreService>();

    return AlertDialog(
      title: const Text('New Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: dropdownValue,
              items: inventoryItems.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
            ),
            TextFormField(
              initialValue: widget.item?.id,
              decoration: const InputDecoration(
                label: Text('ID'),
              ),
              onChanged: (String newValue) {
                setState(() {
                  idValue = newValue;
                });
              },
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'You must set an ID';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                if (widget.formState == InventoryFormState.add) {
                  final item = InventoryItem(id: idValue, type: dropdownValue);
                  await firestoreService.addItem(item);
                } else {
                  final item = InventoryItem(id: idValue, type: dropdownValue);
                  await firestoreService.updateItem(
                    widget.item?.firestoreId,
                    item,
                  );
                }
                Navigator.of(context).pop();
              } catch (e) {
                displayError(
                  context: context,
                  message: 'Error occured while saving inventory item',
                );
              }
            }
          },
        ),
      ],
    );
  }
}
