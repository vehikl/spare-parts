import 'package:flutter/material.dart';
import 'package:spare_parts/entities/inventory_items/laptop.dart';
import 'package:spare_parts/pages/item_page/property_label.dart';

class LaptopData extends StatelessWidget {
  final Laptop laptop;
  const LaptopData({super.key, required this.laptop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ItemPropertyText(
          laptop.serial,
          label: 'Serial Number',
        ),
        ItemPropertyText(
          laptop.formattedPurchaseDate,
          label: 'Purchase Date',
        ),
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ItemPropertyText(
                laptop.year?.toString() ?? 'N/A',
                label: 'Year',
              ),
            ),
            Expanded(
              child: ItemPropertyText(
                laptop.formattedSize,
                label: 'Size',
              ),
            ),
            Expanded(
              child: ItemPropertyText(
                laptop.model ?? 'N/A',
                label: 'Model',
              ),
            ),
            Expanded(
              child: ItemPropertyText(
                laptop.colour ?? 'N/A',
                label: 'Colour',
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ItemPropertyText(
                laptop.build ?? 'N/A',
                label: 'Build',
              ),
            ),
            Expanded(
              child: ItemPropertyText(
                laptop.ram?.toString() ?? 'N/A',
                label: 'RAM',
              ),
            ),
            Expanded(
              child: ItemPropertyText(
                laptop.disk ?? 'N/A',
                label: 'Disk',
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        ItemPropertyText(
          laptop.warranty ?? 'N/A',
          label: 'Warranty',
        ),
      ],
    );
  }
}
