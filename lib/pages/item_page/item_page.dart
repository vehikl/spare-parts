import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/entities/inventory_items/laptop.dart';
import 'package:spare_parts/pages/item_page/item_history.dart';
import 'package:spare_parts/pages/item_page/laptop_data.dart';
import 'package:spare_parts/services/repositories/repositories.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/inventory_list_item/item_actions_button.dart';
import 'package:spare_parts/widgets/item_icon.dart';

class ItemPage extends StatefulWidget {
  final String itemId;

  const ItemPage({super.key, required this.itemId});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  InventoryItemRepository get inventoryItemRepository =>
      context.read<InventoryItemRepository>();
  UserRole get userRole => context.watch<UserRole>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: inventoryItemRepository.getItemStream(widget.itemId),
        builder: (context, AsyncSnapshot<InventoryItem> snapshot) {
          if (snapshot.hasError) {
            return ErrorContainer(error: snapshot.error.toString());
          }

          final item = snapshot.data;
          if (item == null) {
            return Scaffold(
              appBar: AppBar(title: Text('Loading...')),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(title: Text(item.name)),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: ItemIcon(item: item),
                        title: Text(item.name, style: TextStyle(fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.tag_rounded),
                                Text(item.id),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.domain_rounded),
                                Text(item.storageLocation != null
                                    ? item.storageLocation!
                                    : 'N/A'),
                              ],
                            ),
                            if (item is Laptop) LaptopData(laptop: item),
                            if (item.description != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text(
                                    'Description:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(item.description!),
                                ],
                              ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: ItemActionsButton(item: item),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (userRole == UserRole.admin)
                    Expanded(child: ItemHistory(itemId: item.id))
                ],
              ),
            ),
          );
        });
  }
}
