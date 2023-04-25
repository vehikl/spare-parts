import 'package:flutter/material.dart';
import 'package:spare_parts/entities/inventory_items/laptop.dart';
import 'package:spare_parts/utilities/helpers.dart';

class LaptopFormFields extends StatefulWidget {
  final Laptop laptop;
  const LaptopFormFields({super.key, required this.laptop});

  @override
  State<LaptopFormFields> createState() => _LaptopFormFieldsState();
}

class _LaptopFormFieldsState extends State<LaptopFormFields> {
  final TextEditingController _purchaseDateController = TextEditingController();

  @override
  void initState() {
    _purchaseDateController.text = widget.laptop.formattedPurchaseDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: widget.laptop.serial,
          decoration: const InputDecoration(label: Text('Serial Number')),
          onChanged: (String newValue) {
            setState(() {
              widget.laptop.serial = newValue;
            });
          },
          validator: (text) {
            if (text == null || text.isEmpty) {
              return 'You must set a serial number';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _purchaseDateController,
          decoration: const InputDecoration(label: Text('Purchase Date')),
          onTap: () async {
            final value = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            setState(() {
              widget.laptop.purchaseDate = value;
              _purchaseDateController.text = widget.laptop.formattedPurchaseDate;
            });
          },
        ),
      ],
    );
  }
}
