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
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Inventory item document data is null');
    }

    return InventoryItem(
      id: doc.id,
      name: data['name'] ?? doc.id,
      type: data['type'],
      description: data['description'],
      storageLocation: data['storageLocation'],
      borrower: data['borrower'] == null
          ? null
          : CustomUser.fromFirestore(data['borrower']),
      isPrivate: data['isPrivate'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'name': name,
      'description': description,
      'storageLocation': storageLocation,
      'borrower': borrower?.toFirestore(),
      'isPrivate': isPrivate,
    };
  }
}
