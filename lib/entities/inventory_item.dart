import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_items/laptop.dart';

class InventoryItem implements Comparable<InventoryItem> {
  String id;
  String name;
  String? description;
  String? storageLocation;
  String type;
  CustomUser? borrower;
  bool isPrivate;

  InventoryItem({
    required this.id,
    required this.type,
    String? name,
    this.description,
    this.storageLocation,
    this.borrower,
    this.isPrivate = false,
  }) : name = name ?? id;

  String get nameForPrinting => name.length < 20
      ? name
      : "${name.substring(0, 8)}...${name.substring(name.length - 8, name.length)}";

  static InventoryItem fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Inventory item document data is null');
    }

    final type = data['type'];
    if (type == 'Laptop') {
      return Laptop.fromFirestore(doc);
    }

    return InventoryItem(
      id: doc.id,
      name: data['name'],
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

  static InventoryItem fromInventoryItem(InventoryItem item) {
    return InventoryItem(
      id: item.id,
      name: item.name,
      type: item.type,
      description: item.description,
      storageLocation: item.storageLocation,
      borrower: item.borrower,
      isPrivate: item.isPrivate,
    );
  }

  @override
  int compareTo(InventoryItem other) {
    return name.toLowerCase().compareTo(other.name.toLowerCase());
  }
}
