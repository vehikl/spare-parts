import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

import '../../services/repositories/repositories.dart';

class BorrowedItemsView extends StatelessWidget {
  const BorrowedItemsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inventoryItemRepository = context.read<InventoryItemRepository>();
    final auth = context.read<FirebaseAuth>();

    return Center(
      child: StreamBuilder<List<InventoryItem>>(
        stream: inventoryItemRepository.getItemsStream(
          whereBorrowerIs: auth.currentUser?.uid,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorContainer(error: snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;

          if (items.isEmpty) {
            return EmptyListState(
                message: "You don't have any borrowed items yet...");
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              var item = items[index];
              return InventoryListItem(item: item);
            },
          );
        },
      ),
    );
  }
}
