import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/utilities/helpers.dart';

class Laptop extends InventoryItem {
  String serial;
  DateTime? purchaseDate;

  Laptop({
    required super.id,
    required this.serial,
    this.purchaseDate,
    String? name,
    super.description,
    super.storageLocation,
    super.borrower,
    super.isPrivate = false,
  }) : super(type: 'Laptop', name: name);

  String get formattedPurchaseDate {
    if (purchaseDate == null) {
      return 'Not set';
    }

    return formatDate(purchaseDate!, withTime: false);
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      ...super.toFirestore(),
      'serial': serial,
      'purchaseDate': purchaseDate,
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
      serial: data['serial'],
      purchaseDate: data['purchaseDate']?.toDate(),
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
      serial: '',
      description: item.description,
      storageLocation: item.storageLocation,
      borrower: item.borrower,
      isPrivate: item.isPrivate,
    );
  }
}
