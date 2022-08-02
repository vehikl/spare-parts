import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  String id;
  String type;
  String? firestoreId;
  late List<String>? borrowers;

  InventoryItem({
    required this.id,
    required this.type,
    this.firestoreId,
    this.borrowers,
  });

  static InventoryItem fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return InventoryItem(
      id: doc.data()['id'],
      type: doc.data()['type'],
      firestoreId: doc.id,
      borrowers: (doc.data()['borrowers'] != null
              ? doc.data()['borrowers'] as List<dynamic>
              : [])
          .map((b) => b.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'id': id, 'type': type, 'borrowers': borrowers};
  }
}
