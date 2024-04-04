import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';

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
    int limit = kItemsPerPage,
  }) {
    List<Filter> filters = [];

    if (withNoBorrower != null && withNoBorrower) {
      filters.add(Filter('borrower', isNull: true));
    }

    if (whereBorrowerIs != null) {
      filters.add(Filter('borrower.uid', isEqualTo: whereBorrowerIs));
    }

    if (whereBorrowerIn != null) {
      filters.add(Filter('borrower.uid', whereIn: whereBorrowerIn));
    }
    if (whereTypeIn != null) {
      filters.add(Filter('type', whereIn: whereTypeIn));
    }

    if (excludePrivates) {
      filters.add(Filter('isPrivate', isEqualTo: false));
    }

    Query<Object?> query = itemsCollection;

    if (filters.isNotEmpty) {
      Filter andFilter = filters[0];
      for (int i = 1; i < filters.length; i++) {
        andFilter = Filter.and(andFilter, filters[i]);
      }
      query = itemsCollection.where(andFilter);
    }

    return query
        .orderBy('name')
        .limit(limit)
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

  Future<String> add(InventoryItem item) async {
    final docRef = await itemsCollection.add(item.toFirestore());
    return docRef.id;
  }

  Future<void> update(InventoryItem item) async {
    await itemsCollection.doc(item.id).update(item.toFirestore());
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
