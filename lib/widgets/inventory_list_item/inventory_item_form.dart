import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/entities/inventory_items/laptop.dart';
import 'package:spare_parts/services/repositories/repositories.dart';
import 'package:spare_parts/utilities/constants.dart';
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
  late InventoryItem _newItem;

  @override
  void initState() {
    _newItem = InventoryItem(id: '', type: itemTypes.keys.first);
    final item = widget.item;
    if (item != null) {
      _newItem.id = item.id;
      _newItem.type = item.type;
      _newItem.name = item.name;
      _newItem.description = item.description;
      _newItem.isPrivate = item.isPrivate;
      if (item is Laptop) {
        _newItem = Laptop.fromInventoryItem(_newItem);
      }
    }
    super.initState();
  }

  _handleSave() async {
    final inventoryItemRepository = context.read<InventoryItemRepository>();

    if (_formKey.currentState!.validate()) {
      try {
        if (widget.formState == InventoryFormState.add) {
          await inventoryItemRepository.add(_newItem);
        } else {
          await inventoryItemRepository.update(widget.item?.id, _newItem);
        }
        Navigator.of(context).pop();
      } catch (e) {
        showError(
          context: context,
          message: 'Error occured while saving inventory item',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Item'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                initialValue: widget.item?.id,
                decoration: const InputDecoration(label: Text('ID')),
                onChanged: (String newValue) {
                  setState(() {
                    _newItem.id = newValue;
                  });
                },
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'You must set an ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _newItem.name,
                decoration: const InputDecoration(label: Text('Name')),
                onChanged: (String newValue) {
                  setState(() {
                    _newItem.name = newValue;
                  });
                },
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'You must set a name';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _newItem.type,
                decoration: InputDecoration(label: Text('Item Type')),
                items: itemTypes.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue == 'Laptop') {
                      _newItem = Laptop.fromInventoryItem(_newItem);
                    } else {
                      _newItem = InventoryItem.fromInventoryItem(_newItem);
                    }
                    _newItem.type = newValue!;
                  });
                },
              ),
              if (_newItem is Laptop)
                TextFormField(
                  initialValue: (_newItem as Laptop).serialNumber,
                  decoration:
                      const InputDecoration(label: Text('Serial Number')),
                  onChanged: (String newValue) {
                    setState(() {
                      (_newItem as Laptop).serialNumber = newValue;
                    });
                  },
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'You must set a serial number';
                    }
                    return null;
                  },
                ),
              DropdownButtonFormField<String>(
                value: _newItem.storageLocation,
                decoration: InputDecoration(label: Text('Storage Location')),
                items: ['Waterloo', 'London'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _newItem.storageLocation = newValue!;
                  });
                },
              ),
              TextFormField(
                initialValue: _newItem.description,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 1,
                maxLines: 3,
                onChanged: (String newValue) {
                  setState(() {
                    _newItem.description = newValue;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Only visible to admins'),
                value: _newItem.isPrivate,
                onChanged: (value) {
                  setState(() {
                    _newItem.isPrivate = value;
                  });
                },
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(onPressed: _handleSave, child: const Text('Save')),
      ],
    );
  }
}
