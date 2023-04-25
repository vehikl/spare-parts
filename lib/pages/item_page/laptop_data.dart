import 'package:flutter/material.dart';
import 'package:spare_parts/entities/inventory_items/laptop.dart';

class LaptopData extends StatelessWidget {
  final Laptop laptop;
  const LaptopData({super.key, required this.laptop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Serial Number:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(laptop.serial),
        Text(
          'Purchase Date:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(laptop.formattedPurchaseDate),
      ],
    );
  }
}
