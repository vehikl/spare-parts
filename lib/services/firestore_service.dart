import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/entities/event.dart';
import 'package:spare_parts/entities/inventory_item.dart';

class FirestoreService {
  late FirebaseFirestore _firestore;

  FirestoreService(FirebaseFirestore firestore) {
    _firestore = firestore;
  }

  CollectionReference get itemsCollection => _firestore.collection('items');

  DocumentReference getItemDocumentReference(String? itemId) {
    return itemsCollection.doc(itemId);
  }

  deleteItem(String? itemId) async {
    await getItemDocumentReference(itemId).delete();
  }

  borrowItem(InventoryItem item, String? uid) async {
    await getItemDocumentReference(item.firestoreId).update({
      'borrower': uid,
    });
  }

  releaseItem(InventoryItem item) async {
    await getItemDocumentReference(item.firestoreId).update({'borrower': null});
  }

  addItem(InventoryItem item) async {
    await itemsCollection.add(item.toFirestore());
  }

  updateItem(String? itemId, InventoryItem item) async {
    await getItemDocumentReference(itemId).set(item.toFirestore());
  }

  Stream<List<InventoryItem>> getItemsStream({
    String? whereBorrowerIs,
    bool? withNoBorrower,
    List<String>? whereTypesIn,
  }) {
    Query<Object?>? query;

    if (withNoBorrower != null && withNoBorrower) {
      query = itemsCollection.where('borrower', isNull: true);
    }

    if (whereBorrowerIs != null) {
      query = itemsCollection.where('borrower', isEqualTo: whereBorrowerIs);
    }

    if (whereTypesIn != null) {
      query = (query ?? itemsCollection).where('type', whereIn: whereTypesIn);
    }

    return (query ?? itemsCollection)
        .snapshots()
        .map(_mapQuerySnapshotToInventoryItems);
  }

  List<InventoryItem> _mapQuerySnapshotToInventoryItems(
    QuerySnapshot<Object?> snapshot,
  ) {
    return snapshot.docs
        .map((doc) => InventoryItem.fromFirestore(
            doc as QueryDocumentSnapshot<Map<String, dynamic>>))
        .toList();
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

  Future<void> addEvent(String inventoryItemId, Event event) async {
    await itemsCollection
        .doc(inventoryItemId)
        .collection('events')
        .add(event.toFirestore());
  }
}
