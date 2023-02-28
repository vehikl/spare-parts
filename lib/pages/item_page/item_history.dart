import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/event.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';

class ItemHistory extends StatelessWidget {
  final String itemId;

  const ItemHistory({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text('Interaction History', style: TextStyle(fontSize: 18)),
        ),
        StreamBuilder<List<Event>>(
          stream: firestoreService.getEventsStream(itemId),
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

            return ListView(
              shrinkWrap: true,
              children: events
                  .map((event) => ListTile(
                        visualDensity: VisualDensity(
                          vertical: VisualDensity.minimumDensity,
                        ),
                        title: Text(event.issuerName),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(event.type),
                            Text(
                              event.createdAt == null
                                  ? 'N/A'
                                  : DateFormat.yMMMd().format(event.createdAt!),
                            )
                          ],
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
