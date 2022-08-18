import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/models/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

class BorrowedItemsView extends StatelessWidget {
  const BorrowedItemsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final auth = context.read<FirebaseAuth>();

    return Center(
      child: StreamBuilder<List<InventoryItem>>(
        stream: firestoreService.getItemsStream(
          whereBorrowerIs: auth.currentUser?.uid,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.red,
              ),
              padding: const EdgeInsets.all(16),
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) return Center(child: Text('Loading...'));

          final items = snapshot.data!;
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
        },
      ),
    );
  }
}
