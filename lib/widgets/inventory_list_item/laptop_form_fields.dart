import 'package:flutter/material.dart';
import 'package:spare_parts/entities/inventory_items/laptop.dart';
import 'package:spare_parts/widgets/inputs/numeric_form_field.dart';

class LaptopFormFields extends StatefulWidget {
  final Laptop laptop;
  final double spacing;

  const LaptopFormFields({
    super.key,
    required this.laptop,
    required this.spacing,
  });

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
          decoration: const InputDecoration(label: Text('Serial Number *')),
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
        SizedBox(height: widget.spacing),
        TextFormField(
          controller: _purchaseDateController,
          decoration: const InputDecoration(
            label: Text('Purchase Date'),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final value = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            setState(() {
              widget.laptop.purchaseDate = value;
              _purchaseDateController.text =
                  widget.laptop.formattedPurchaseDate;
            });
          },
        ),
        SizedBox(height: widget.spacing),
        NumericFormField(
          initValue: widget.laptop.year,
          label: 'Year',
          onChanged: (newYear) {
            setState(() {
              widget.laptop.year = newYear;
            });
          },
        ),
        SizedBox(height: widget.spacing),
        NumericFormField(
          initValue: widget.laptop.size,
          label: 'Size (In.)',
          onChanged: (newSize) {
            setState(() {
              widget.laptop.size = newSize;
            });
          },
        ),
        SizedBox(height: widget.spacing),
        TextFormField(
          initialValue: widget.laptop.model,
          decoration: const InputDecoration(label: Text('Model')),
          onChanged: (String newValue) {
            setState(() {
              widget.laptop.model = newValue == "" ? null : newValue;
            });
          },
        ),
        SizedBox(height: widget.spacing),
        TextFormField(
          initialValue: widget.laptop.colour,
          decoration: const InputDecoration(label: Text('Colour')),
          onChanged: (String newValue) {
            setState(() {
              widget.laptop.colour = newValue == "" ? null : newValue;
            });
          },
        ),
        SizedBox(height: widget.spacing),
        TextFormField(
          initialValue: widget.laptop.build,
          decoration: const InputDecoration(label: Text('Build')),
          onChanged: (String newValue) {
            setState(() {
              widget.laptop.build = newValue == "" ? null : newValue;
            });
          },
        ),
        SizedBox(height: widget.spacing),
        NumericFormField(
          initValue: widget.laptop.ram,
          label: 'RAM (GB)',
          onChanged: (newRam) {
            setState(() {
              widget.laptop.ram = newRam;
            });
          },
        ),
        SizedBox(height: widget.spacing),
        TextFormField(
          initialValue: widget.laptop.disk,
          decoration: const InputDecoration(label: Text('Disk')),
          onChanged: (String newValue) {
            setState(() {
              widget.laptop.disk = newValue == "" ? null : newValue;
            });
          },
        ),
        SizedBox(height: widget.spacing),
        TextFormField(
          initialValue: widget.laptop.warranty,
          decoration: const InputDecoration(label: Text('Warranty')),
          onChanged: (String newValue) {
            setState(() {
              widget.laptop.warranty = newValue == "" ? null : newValue;
            });
          },
        ),
      ],
    );
  }
}
