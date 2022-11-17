import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/entities/custom_user.dart';

class InventoryItem {
  String id;
  String type;
  CustomUser? borrower;

  InventoryItem({required this.id, required this.type, this.borrower});

  static InventoryItem fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return InventoryItem(
      id: doc.id,
      type: doc.data()['type'],
      borrower: doc.data()['borrower'] == null
          ? null
          : CustomUser.fromFirestore(doc.data()['borrower']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'borrower': borrower?.toFirestore(),
      'borrowerId': borrower?.uid,
    };
  }
}
