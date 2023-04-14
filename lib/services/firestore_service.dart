import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/entities/borrowing_response.dart';
import 'package:spare_parts/entities/borrowing_rule.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/event.dart';

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

  Stream<List<BorrowingRule>> borrowingRulesStream() {
    return borrowingRulesCollection.snapshots().map((e) => e.docs
        .map((doc) => BorrowingRule.fromFirestore(
            doc as QueryDocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  Future<BorrowingRule?> getBorrowingRuleForItemType(String itemType) async {
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

  Future<void> addBorrowingRequest(BorrowingRequest borrowingRequest) async {
    await borrowingRequestsCollection.add(borrowingRequest.toFirestore());
  }

  Future<void> deleteBorrowingRequest(String? borrowingRequestId) async {
    await borrowingRequestsCollection.doc(borrowingRequestId).delete();
  }

  Stream<List<BorrowingRequest>> getBorrowingRequestsStream({
    String? whereIssuerIs,
    bool? processed,
  }) {
    Query<Object?>? query;

    if (whereIssuerIs != null) {
      query = borrowingRequestsCollection.where(
        'issuer.uid',
        isEqualTo: whereIssuerIs,
      );
    }

    if (processed != null) {
      if (processed) {
        query = (query ?? borrowingRequestsCollection)
            .where('response.approved', whereIn: [true, false]);
      } else {
        query = (query ?? borrowingRequestsCollection).where(
          'response',
          isNull: true,
        );
      }
    }

    return (query ?? borrowingRequestsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => BorrowingRequest.fromFirestore(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  Future<BorrowingRequest?> getPendingBorrowingRequestForInventoryItem(
    String inventoryItemId,
  ) async {
    final itemRequestsQuery = await borrowingRequestsCollection
        .where('item.id', isEqualTo: inventoryItemId)
        .where('response', isNull: true)
        .get();
    if (itemRequestsQuery.docs.isEmpty) return null;

    return BorrowingRequest.fromFirestore(
      itemRequestsQuery.docs.first
          as QueryDocumentSnapshot<Map<String, dynamic>>,
    );
  }

  Future<void> makeDecisionOnBorrowingRequest({
    required CustomUser decisionMaker,
    required BorrowingRequest borrowingRequest,
    required bool isApproved,
  }) async {
    borrowingRequest.response = BorrowingResponse(
      decisionMaker: decisionMaker,
      approved: isApproved,
    );
    final borrowingRequestId = borrowingRequest.id;
    await borrowingRequestsCollection
        .doc(borrowingRequestId)
        .update(borrowingRequest.toFirestore());
  }
}
