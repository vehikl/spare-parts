import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/business_logic/item_action.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    return Center(
      child: StreamBuilder<List<InventoryItem>>(
        stream: firestoreService.getItemsStream(withNoBorrower: true),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorContainer(error: snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;

          if (items.isEmpty) {
            return EmptyListState(message: "No inventory items to display...");
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return InventoryListItem(
                item: items[index],
                actions: [BorrowItemAction()],
              );
            },
          );
        },
      ),
    );
  }
}
