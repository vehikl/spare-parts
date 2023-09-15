import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/services/repositories/repository.dart';

@GenerateNiceMocks([MockSpec<InventoryItemRepository>()])
class InventoryItemRepository extends Repository {
  final FirestoreService firestoreService;

  InventoryItemRepository({ required this.firestoreService});

  @override
  CollectionReference<Map<String, dynamic>> get collection => firestoreService.itemsCollection;

  DocumentReference getItemDocumentReference(String? itemId) {
    return collection.doc(itemId);
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
      query = collection.where('borrower', isNull: true);
    }

    if (whereBorrowerIs != null) {
      query = collection.where('borrower.uid', isEqualTo: whereBorrowerIs);
    }

    if (whereBorrowerIn != null) {
      query = (query ?? collection).where(
        'borrower.uid',
        whereIn: whereBorrowerIn,
      );
    }

    if (whereTypeIn != null) {
      query = (query ?? collection).where('type', whereIn: whereTypeIn);
    }

    if (excludePrivates) {
      query = (query ?? collection).where('isPrivate', isEqualTo: false);
    }

    return (query ?? collection)
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

  Future<String> addItem(InventoryItem item) async {
    return await super.add(item.toFirestore());
  }

  Future<void> update(InventoryItem item) async {
    await collection.doc(item.id).update(item.toFirestore());
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
