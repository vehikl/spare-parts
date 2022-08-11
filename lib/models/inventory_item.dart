import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  String id;
  String type;
  String? firestoreId;
  late String? borrower;

  InventoryItem({
    required this.id,
    required this.type,
    this.firestoreId,
    this.borrower
  });

  static InventoryItem fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return InventoryItem(
      id: doc.data()['id'],
      type: doc.data()['type'],
      firestoreId: doc.id,
      borrower: doc.data()['borrower'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'id': id, 'type': type, 'borrower': borrower};
  }
}
