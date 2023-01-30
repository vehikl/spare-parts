import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowingRule {
  String? id;
  String type;
  int maxBorrowingCount;

  BorrowingRule({
    this.id,
    required this.type,
    required this.maxBorrowingCount,
  });

  static BorrowingRule fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return BorrowingRule(
      id: doc.id,
      type: doc.data()['type'],
      maxBorrowingCount: doc.data()['maxBorrowingCount'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type,
      'maxBorrowingCount': maxBorrowingCount,
    };
  }
}
