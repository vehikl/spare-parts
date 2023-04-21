import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';

@GenerateNiceMocks([MockSpec<InventoryItemRepository>()])
class InventoryItemRepository extends FirestoreService {
  InventoryItemRepository(super.firestore);

  DocumentReference getItemDocumentReference(String? itemId) {
    return itemsCollection.doc(itemId);
  }

  Stream<InventoryItem> getItemStream(String? itemId) {
    return getItemDocumentReference(itemId).snapshots().map(
          (e) => InventoryItem.fromFirestore(
            e as DocumentSnapshot<Map<String, dynamic>>,
          ),
        );
  }

  Stream<List<InventoryItem>> getItemsStream({
    bool? withNoBorrower,
    String? whereBorrowerIs,
    List<String>? whereBorrowerIn,
    List<String>? whereTypeIn,
    bool excludePrivates = false,
  }) {
    Query<Object?>? query;

    if (withNoBorrower != null && withNoBorrower) {
      query = itemsCollection.where('borrower', isNull: true);
    }

    if (whereBorrowerIs != null) {
      query = itemsCollection.where('borrower.uid', isEqualTo: whereBorrowerIs);
    }

    if (whereBorrowerIn != null) {
      query = (query ?? itemsCollection).where(
        'borrower.uid',
        whereIn: whereBorrowerIn,
      );
    }

    if (whereTypeIn != null) {
      query = (query ?? itemsCollection).where('type', whereIn: whereTypeIn);
    }

    if (excludePrivates) {
      query = (query ?? itemsCollection).where('isPrivate', isEqualTo: false);
    }

    return (query ?? itemsCollection)
        .snapshots()
        .map(_mapQuerySnapshotToInventoryItems);
  }

  Future<void> delete(String? itemId) async {
    await getItemDocumentReference(itemId).delete();
  }

  Future<void> borrow(InventoryItem item, CustomUser user) async {
    await getItemDocumentReference(item.id).update({
      'borrower': user.toFirestore(),
    });
  }

  Future<void> release(InventoryItem item) async {
    await getItemDocumentReference(item.id).update({
      'borrower': null,
    });
  }

  Future<void> add(InventoryItem item) async {
    await itemsCollection.doc(item.id).set(item.toFirestore());
  }

  Future<void> update(String? itemId, InventoryItem item) async {
    await delete(itemId);
    await add(item);
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
