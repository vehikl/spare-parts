import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:spare_parts/entities/event.dart';
import 'package:spare_parts/entities/inventory_item.dart';

@GenerateNiceMocks([MockSpec<FirestoreService>()])
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
    await getItemDocumentReference(item.id).update({
      'borrower': uid,
    });
  }

  releaseItem(InventoryItem item) async {
    await getItemDocumentReference(item.id).update({'borrower': null});
  }

  addItem(InventoryItem item) async {
    await itemsCollection.doc(item.id).set(item.toFirestore());
  }

  updateItem(String? itemId, InventoryItem item) async {
    await deleteItem(itemId);
    await addItem(item);
  }

  Stream<List<InventoryItem>> getItemsStream({
    bool? withNoBorrower,
    String? whereBorrowerIs,
    List<String>? whereBorrowerIn,
    List<String>? whereTypeIn,
  }) {
    Query<Object?>? query;

    if (withNoBorrower != null && withNoBorrower) {
      query = itemsCollection.where('borrower', isNull: true);
    }

    if (whereBorrowerIs != null) {
      query = itemsCollection.where('borrower', isEqualTo: whereBorrowerIs);
    }

    if (whereBorrowerIn != null) {
      query = (query ?? itemsCollection).where(
        'borrower',
        whereIn: whereBorrowerIn,
      );
    }

    if (whereTypeIn != null) {
      query = (query ?? itemsCollection).where('type', whereIn: whereTypeIn);
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
