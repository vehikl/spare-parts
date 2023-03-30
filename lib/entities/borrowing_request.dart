import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/entities/borrowing_response.dart';
import 'package:spare_parts/entities/inventory_item.dart';

class BorrowingRequest {
  String? id;
  late String issuerId;
  late BorrowingRequestItem item;
  DateTime? createdAt;
  BorrowingResponse? response;

  BorrowingRequest({
    this.id,
    required this.issuerId,
    required this.item,
    this.createdAt,
    this.response,
  });

  static BorrowingRequest fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return BorrowingRequest(
        id: doc.id,
        issuerId: doc.data()['issuerId'],
        item: BorrowingRequestItem.fromFirestore(doc.data()['item']),
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
      'item': item.toFirestore(),
      'createdAt':
          createdAt == null ? Timestamp.now() : Timestamp.fromDate(createdAt!),
      'response': response == null ? null : response!.toFirestore(),
    };
  }
}

class BorrowingRequestItem {
  String id;
  String type;
  String? name;

  BorrowingRequestItem({
    required this.id,
    required this.type,
    this.name,
  });

  static BorrowingRequestItem fromFirestore(Map<String, dynamic> data) {
    return BorrowingRequestItem(
        id: data['id'], name: data['name'], type: data['type']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }

  static BorrowingRequestItem fromInventoryItem(InventoryItem item) {
    return BorrowingRequestItem(id: item.id, name: item.name, type: item.type);
  }
}
