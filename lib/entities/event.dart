import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String? id;
  String issuerName;
  String issuerId;
  String type;

  Event({
    this.id,
    required this.issuerName,
    required this.issuerId,
    required this.type,
  });

  static Event fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return Event(
      id: doc.data()['id'],
      issuerName: doc.data()['issuerName'],
      issuerId: doc.data()['issuerId'],
      type: doc.data()['type'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'issuerName': issuerName,
      'issuerId': issuerId,
      'type': type,
    };
  }
}
