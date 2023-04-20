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
  String _newId = '';
  String _newName = '';
  String? _newDescription;
  String _newType = itemTypes.keys.first;
  String? _newStorageLocation;
  bool _newIsPrivate = false;

  String _serialNumber = '';

  @override
  void initState() {
    final item = widget.item;
    if (item != null) {
      _newId = item.id;
      _newType = item.type;
      _newName = item.name;
      _newDescription = item.description;
      _newIsPrivate = item.isPrivate;
      if (item is Laptop) {
        _serialNumber = item.serialNumber;
      }
    }
    super.initState();
  }

  _handleSave() async {
    final inventoryItemRepository = context.read<InventoryItemRepository>();

    if (_formKey.currentState!.validate()) {
      try {
        final item = widget.item is Laptop
            ? Laptop(
                id: _newId,
                name: _newName,
                serialNumber: _serialNumber,
                description: _newDescription,
                storageLocation: _newStorageLocation,
                isPrivate: _newIsPrivate,
              )
            : InventoryItem(
                id: _newId,
                type: _newType,
                name: _newName,
                description: _newDescription,
                storageLocation: _newStorageLocation,
                isPrivate: _newIsPrivate,
              );
        if (widget.formState == InventoryFormState.add) {
          await inventoryItemRepository.add(item);
        } else {
          await inventoryItemRepository.update(widget.item?.id, item);
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
                    _newId = newValue;
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
                initialValue: _newName,
                decoration: const InputDecoration(label: Text('Name')),
                onChanged: (String newValue) {
                  setState(() {
                    _newName = newValue;
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
                value: _newType,
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
                    _newType = newValue!;
                  });
                },
              ),
              if (widget.item is Laptop)
                TextFormField(
                  initialValue: _serialNumber,
                  decoration:
                      const InputDecoration(label: Text('Serial Number')),
                  onChanged: (String newValue) {
                    setState(() {
                      _serialNumber = newValue;
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
                value: _newStorageLocation,
                decoration: InputDecoration(label: Text('Storage Location')),
                items: ['Waterloo', 'London'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _newStorageLocation = newValue!;
                  });
                },
              ),
              TextFormField(
                initialValue: _newDescription,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 1,
                maxLines: 3,
                onChanged: (String newValue) {
                  setState(() {
                    _newDescription = newValue;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Only visible to admins'),
                value: _newIsPrivate,
                onChanged: (value) {
                  setState(() {
                    _newIsPrivate = value;
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
