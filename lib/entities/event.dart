import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String? id;
  String issuerName;
  String issuerId;
  String type;
  DateTime? createdAt;

  Event({
    this.id,
    this.createdAt,
    required this.issuerName,
    required this.issuerId,
    required this.type,
  });

  static Event fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return Event(
        id: doc.id,
        issuerName: doc.data()['issuerName'],
        issuerId: doc.data()['issuerId'],
        type: doc.data()['type'],
        createdAt: doc.data()['createdAt'] != null
            ? (doc.data()['createdAt'] as Timestamp).toDate()
            : null);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'issuerName': issuerName,
      'issuerId': issuerId,
      'type': type,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
  }
}
