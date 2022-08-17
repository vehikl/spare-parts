import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/models/inventory_item.dart';

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

  Stream<List<InventoryItem>> getBorrowedItemsStream(String? uid) {
    return itemsCollection
        .where('borrower', isEqualTo: uid)
        .snapshots()
        .map(_mapQuerySnapshotToInventoryItems);
  }

  Stream<List<InventoryItem>> getInventoryItemsStream() {
    return itemsCollection
        .where('borrower', isNull: true)
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
}