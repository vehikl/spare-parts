import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';

class Laptop extends InventoryItem {
  String serialNumber;

  Laptop({
    required super.id,
    required this.serialNumber,
    String? name,
    super.description,
    super.storageLocation,
    super.borrower,
    super.isPrivate = false,
  }) : super(type: 'Laptop', name: name);

  @override
  Map<String, dynamic> toFirestore() {
    return {
      ...super.toFirestore(),
      'serialNumber': serialNumber,
    };
  }

  static Laptop fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Inventory item document data is null');
    }

    return Laptop(
      id: doc.id,
      name: data['name'] ?? doc.id,
      serialNumber: data['serialNumber'],
      description: data['description'],
      storageLocation: data['storageLocation'],
      borrower: data['borrower'] == null
          ? null
          : CustomUser.fromFirestore(data['borrower']),
      isPrivate: data['isPrivate'] ?? false,
    );
  }

  static Laptop fromInventoryItem(InventoryItem item) {
    if (item is Laptop) {
      return item;
    }

    return Laptop(
      id: item.id,
      name: item.name,
      serialNumber: '',
      description: item.description,
      storageLocation: item.storageLocation,
      borrower: item.borrower,
      isPrivate: item.isPrivate,
    );
  }
}
