import 'package:flutter/material.dart';
import 'package:spare_parts/constants.dart';

class InventoryListItem extends StatelessWidget {
  const InventoryListItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(inventoryItems[item['type']]),
      title: Text(
        item['id'],
        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 22),
      ),
    );
  }
}
