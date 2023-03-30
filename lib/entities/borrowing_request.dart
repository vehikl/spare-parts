import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/entities/borrowing_response.dart';

class BorrowingRequest {
  String? id;
  late String issuerId;
  late String itemId;
  DateTime? createdAt;
  BorrowingResponse? response;

  BorrowingRequest({
    this.id,
    required this.issuerId,
    required this.itemId,
    this.createdAt,
    this.response,
  });

  static BorrowingRequest fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return BorrowingRequest(
        id: doc.id,
        issuerId: doc.data()['issuerId'],
        itemId: doc.data()['itemId'],
        createdAt: doc.data()['createdAt'] != null
            ? (doc.data()['createdAt'] as Timestamp).toDate()
            : null,
        response: doc.data()['response'] != null
            ? BorrowingResponse.fromFirestore(doc.data()['response'])
            : null);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'issuerId': issuerId,
      'itemId': itemId,
      'createdAt':
          createdAt == null ? Timestamp.now() : Timestamp.fromDate(createdAt!),
      'response': response == null ? null : response!.toFirestore(),
    };
  }
}
