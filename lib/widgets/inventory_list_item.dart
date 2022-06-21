import 'package:flutter/material.dart';

class InventoryListItem extends StatelessWidget {
  const InventoryListItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        item['id'],
        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 22),
      ),
    );
  }
}
