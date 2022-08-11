import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/models/inventory_item.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirebaseFirestore>();
    return Center(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore
            .collection('items')
            .where('borrower', isNull: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.error == null) {
            final items = (snapshot.data?.docs ?? [])
                .map(InventoryItem.fromFirestore)
                .toList();

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                var item = items[index];
                return InventoryListItem(
                  item: item,
                  actions: const [ItemAction.borrow],
                );
              },
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.red,
              ),
              padding: const EdgeInsets.all(16),
              child: Text(snapshot.error.toString()),
            );
          }
        },
      ),
    );
  }
}
