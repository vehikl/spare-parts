import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/event.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/entities/inventory_items/laptop.dart';
import 'package:spare_parts/services/repositories/repositories.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/utilities/helpers.dart';
import 'package:spare_parts/widgets/buttons/async_elevated_button.dart';
import 'package:spare_parts/widgets/inventory_list_item/laptop_form_fields.dart';
import 'package:spare_parts/widgets/inventory_list_item/name_generation_button.dart';

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
  final _nameController = TextEditingController();

  @override
  void initState() {
    _newItem = InventoryItem(id: '', type: itemTypes.keys.first);
    final item = widget.item;
    if (item != null) {
      if (item is Laptop) {
        _newItem = Laptop.fromInventoryItem(item);
      } else {
        _newItem = InventoryItem.fromInventoryItem(item);
      }
    }

    _nameController.text = _newItem.name;

    super.initState();
  }

  Future<void> _handleSave() async {
    final inventoryItemRepository = context.read<InventoryItemRepository>();
    final eventRepository = context.read<EventRepository>();
    final auth = context.read<FirebaseAuth>();

    if (_formKey.currentState!.validate()) {
      try {
        if (widget.formState == InventoryFormState.add) {
          final newItemId = await inventoryItemRepository.add(_newItem);

          final event = Event(
            issuerId: auth.currentUser!.uid,
            issuerName: auth.currentUser!.displayName ?? 'anonymous',
            type: 'Create',
            createdAt: DateTime.now(),
          );
          await eventRepository.addEvent(newItemId, event);
        } else {
          await inventoryItemRepository.update(_newItem);
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
                controller: _nameController,
                decoration: InputDecoration(
                  label: Text('Name'),
                  suffixIcon: NameGenerationButton(
                    itemType: _newItem.type,
                    onGenerate: (newName) {
                      setState(() {
                        _newItem.name = newName;
                        _nameController.text = newName;
                      });
                    },
                  ),
                ),
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
                LaptopFormFields(laptop: _newItem as Laptop),
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
        AsyncElevatedButton(onPressed: _handleSave, text: 'Save'),
      ],
    );
  }
}
