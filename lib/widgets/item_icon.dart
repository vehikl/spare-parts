import 'package:flutter/material.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/utilities/constants.dart';

class ItemIcon extends StatelessWidget {
  final InventoryItem item;

  const ItemIcon({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(itemTypes[item.type]),
        if (item.isPrivate)
          Positioned(
            bottom: -3,
            right: -5,
            child: Icon(
              Icons.visibility_off,
              size: 13,
              color: Colors.black,
            ),
          ),
      ],
    );
  }
}
