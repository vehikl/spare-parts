import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/event.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';

class EventHistoryModal extends StatelessWidget {
  final InventoryItem item;

  const EventHistoryModal({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Interaction History', style: TextStyle(fontSize: 20)),
          ),
          Card(
            child: ListTile(
              leading: Icon(itemTypes[item.type]),
              title: Text(item.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${item.id}'),
                  Row(
                    children: [
                      Icon(Icons.domain_rounded),
                      Text(item.storageLocation != null
                          ? item.storageLocation!
                          : 'N/A'),
                    ],
                  ),
                  if (item.description != null) Text(item.description!),
                ],
              ),
              isThreeLine: true,
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
                            title: Text(event.issuerName),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }
}
