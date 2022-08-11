import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/models/inventory_item.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

class BorrowedItemsView extends StatelessWidget {
  const BorrowedItemsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirebaseFirestore>();
    final auth = context.read<FirebaseAuth>();

    return Center(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore
            .collection('items')
            .where('borrower', isEqualTo: auth.currentUser?.uid)
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
                  actions: const [ItemAction.release],
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
