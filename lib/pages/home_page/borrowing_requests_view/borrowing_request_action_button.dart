import 'package:flutter/material.dart';
import 'package:spare_parts/entities/inventory_item.dart';

class BorrowingRequestActionsButton extends StatelessWidget {
  const BorrowingRequestActionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Icon(Icons.more_vert),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'approve',
          child: Row(
            children: [
              Icon(Icons.check),
              SizedBox(width: 4),
              Text('Approve'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'deny',
          child: Row(
            children: [
              Icon(Icons.close),
              SizedBox(width: 4),
              Text('Deny'),
            ],
          ),
        )
      ],
      onSelected: (_) => {},
    );
  }
}
