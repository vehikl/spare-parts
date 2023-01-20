import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/event.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/item_icon.dart';

class ItemPage extends StatelessWidget {
  final InventoryItem item;

  const ItemPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

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
                      if (item.description != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              'Description:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(item.description!),
                          ],
                        ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Interaction History',
                style: TextStyle(fontSize: 18),
              ),
            ),
            StreamBuilder<List<Event>>(
              stream: firestoreService.getEventsStream(item.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorContainer(error: snapshot.error.toString());
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data!;

                if (events.isEmpty) {
                  return EmptyListState(
                      message: "This item was not borrowed yet...");
                }

                return Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: events
                        .map((event) => ListTile(
                              visualDensity: VisualDensity(
                                vertical: VisualDensity.minimumDensity,
                              ),
                              title: Text(event.issuerName),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(event.type),
                                  Text(
                                    event.createdAt == null
                                        ? 'N/A'
                                        : DateFormat.yMMMd()
                                            .format(event.createdAt!),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
