import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddInventoryItemForm extends StatefulWidget {
  const AddInventoryItemForm({Key? key}) : super(key: key);

  @override
  State<AddInventoryItemForm> createState() => _AddInventoryItemFormState();
}

class _AddInventoryItemFormState extends State<AddInventoryItemForm> {
  final _formKey = GlobalKey<FormState>();
  String dropdownValue = 'Chair';
  String idValue = '';

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirebaseFirestore>();

    return AlertDialog(
      title: const Text('New Item'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: dropdownValue,
              items: <String>["Chair", "Desk", "Monitor", "Laptop"]
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
        TextButton(
          child: const Text('Add'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await firestore
                  .collection('Items')
                  .add({'id': idValue, 'type': dropdownValue});
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
