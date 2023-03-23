import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/entities/borrowing_rule.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/event.dart';
import 'package:spare_parts/entities/inventory_item.dart';

@GenerateNiceMocks([MockSpec<FirestoreService>()])
class FirestoreService {
  late FirebaseFirestore _firestore;

  FirestoreService(FirebaseFirestore firestore) {
    _firestore = firestore;
  }

  CollectionReference get itemsCollection => _firestore.collection('items');
  CollectionReference get borrowingRulesCollection =>
      _firestore.collection('borrowingRules');

  CollectionReference get borrowingRequestsCollection =>
      _firestore.collection('borrowingRequests');

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

  Future<void> addBorrowingRequest(BorrowingRequest borrowingRequest) async {
    await borrowingRequestsCollection.add(borrowingRequest.toFirestore());
  }

  Stream<List<BorrowingRule>> borrowingRulesStream() {
    return borrowingRulesCollection.snapshots().map((e) => e.docs
        .map((doc) => BorrowingRule.fromFirestore(
            doc as QueryDocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  Future<BorrowingRule?> getBorrowingRuleForItemItemType(
      String itemType) async {
    final borrowingRuleDocs =
        await borrowingRulesCollection.where('type', isEqualTo: itemType).get();

    if (borrowingRuleDocs.docs.isEmpty) return null;

    return BorrowingRule.fromFirestore(borrowingRuleDocs.docs.first
        as QueryDocumentSnapshot<Map<String, dynamic>>);
  }

  Future<void> updateBorrowingRule(BorrowingRule borrowingRule) async {
    await borrowingRulesCollection.doc(borrowingRule.id).update(
          borrowingRule.toFirestore(),
        );
  }

  Future<void> addBorrowingRule(BorrowingRule borrowingRule) async {
    await borrowingRulesCollection.add(borrowingRule.toFirestore());
  }

  Future<void> deleteBorrowingRule(BorrowingRule borrowingRule) async {
    await borrowingRulesCollection.doc(borrowingRule.id).delete();
  }

  Future<dynamic> getBorrowingCount(String itemType, String uid) async {
    final items = await itemsCollection
        .where('type', isEqualTo: itemType)
        .where('borrowerId', isEqualTo: uid)
        .get();

    return items.docs.length;
  }

  deleteItem(String? itemId) async {
    await getItemDocumentReference(itemId).delete();
  }

  borrowItem(InventoryItem item, CustomUser user) async {
    await getItemDocumentReference(item.id).update({
      'borrower': user.toFirestore(),
      'borrowerId': user.uid,
    });
  }

  releaseItem(InventoryItem item) async {
    await getItemDocumentReference(item.id).update({
      'borrower': null,
      'borrowerId': null,
    });
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
    bool excludePrivates = false,
  }) {
    Query<Object?>? query;

    if (withNoBorrower != null && withNoBorrower) {
      query = itemsCollection.where('borrowerId', isNull: true);
    }

    if (whereBorrowerIs != null) {
      query = itemsCollection.where('borrowerId', isEqualTo: whereBorrowerIs);
    }

    if (whereBorrowerIn != null) {
      query = (query ?? itemsCollection).where(
        'borrowerId',
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
