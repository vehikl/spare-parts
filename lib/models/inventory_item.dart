import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  String id;
  String type;
  String? firestoreId;

  InventoryItem({
    required this.id,
    required this.type,
    this.firestoreId,
  });

  static InventoryItem fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return InventoryItem(
      id: doc.data()['id'],
      type: doc.data()['type'],
      firestoreId: doc.id,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'id': id, 'type': type};
  }
}
