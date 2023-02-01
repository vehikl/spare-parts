import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowingRule {
  String? id;
  String type;
  int maxBorrowingCount;
  DateTime? createdAt;

  BorrowingRule({
    this.id,
    required this.type,
    required this.maxBorrowingCount,
    this.createdAt,
  });

  BorrowingRule get copy => BorrowingRule(
        id: id,
        type: type,
        maxBorrowingCount: maxBorrowingCount,
        createdAt: createdAt,
      );

  void increase() {
    maxBorrowingCount++;
  }

  void decrease() {
    maxBorrowingCount--;
  }

  static BorrowingRule fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return BorrowingRule(
      id: doc.id,
      type: doc.data()['type'],
      maxBorrowingCount: doc.data()['maxBorrowingCount'],
      createdAt: doc.data()['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'maxBorrowingCount': maxBorrowingCount,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
