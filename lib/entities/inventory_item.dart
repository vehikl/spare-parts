import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/entities/custom_user.dart';

class InventoryItem {
  String id;
  String name;
  String? description;
  String? storageLocation;
  String type;
  CustomUser? borrower;
  bool isPrivate;

  InventoryItem(
      {required this.id,
      required this.type,
      String? name,
      this.description,
      this.storageLocation,
      this.borrower,
      this.isPrivate = false})
      : name = name ?? id;

  static InventoryItem fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return InventoryItem(
      id: doc.id,
      name: doc.data()['name'] ?? doc.id,
      type: doc.data()['type'],
      description: doc.data()['description'],
      storageLocation: doc.data()['storageLocation'],
      borrower: doc.data()['borrower'] == null
          ? null
          : CustomUser.fromFirestore(doc.data()['borrower']),
      isPrivate: doc.data()['isPrivate'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'name': name,
      'description': description,
      'storageLocation': storageLocation,
      'borrower': borrower?.toFirestore(),
      'borrowerId': borrower?.uid,
      'isPrivate': isPrivate,
    };
  }
}
