import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spare_parts/entities/event.dart';
import 'package:spare_parts/services/firestore_service.dart';

class EventRepository extends FirestoreService {
  late final FirebaseAuth _auth;

  EventRepository(FirebaseFirestore firestore, FirebaseAuth auth)
      : super(firestore) {
    _auth = auth;
  }

  Stream<List<Event>> getEventsStream(String? inventoryItemId) {
    return itemsCollection
        .doc(inventoryItemId)
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  Future<void> add(String inventoryItemId, {required String eventType}) async {
    final event = Event(
      issuerId: _auth.currentUser!.uid,
      issuerName: _auth.currentUser?.displayName ?? 'anonymous',
      type: eventType,
      createdAt: DateTime.now(),
    );

    await itemsCollection
        .doc(inventoryItemId)
        .collection('events')
        .add(event.toFirestore());
  }
}
