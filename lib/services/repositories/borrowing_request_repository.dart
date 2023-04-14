import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/entities/borrowing_response.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/services/firestore_service.dart';

class BorrowingRequestRepository extends FirestoreService {
  BorrowingRequestRepository(super.firestore);

Future<void> add(BorrowingRequest borrowingRequest) async {
    await borrowingRequestsCollection.add(borrowingRequest.toFirestore());
  }

  Future<void> delete(String? borrowingRequestId) async {
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

  Future<BorrowingRequest?> getPendingForInventoryItem(
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

  Future<void> makeDecision({
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