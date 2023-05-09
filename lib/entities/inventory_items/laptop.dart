import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/utilities/helpers.dart';

class Laptop extends InventoryItem {
  String serial;
  DateTime? purchaseDate;
  int? year;
  int? size;
  String? model;
  String? colour;
  String? build;
  int? ram;
  String? disk;
  String? warranty;

  Laptop({
    required super.id,
    required this.serial,
    this.purchaseDate,
    this.year,
    this.size,
    this.model,
    this.colour,
    this.build,
    this.ram,
    this.disk,
    this.warranty,
    String? name,
    super.description,
    super.storageLocation,
    super.borrower,
    super.isPrivate = false,
  }) : super(type: 'Laptop', name: name);

  String get formattedPurchaseDate {
    if (purchaseDate == null) {
      return 'N/A';
    }

    return formatDate(purchaseDate!, withTime: false);
  }

  String get formattedSize {
    if (size == null) {
      return 'N/A';
    }

    return '$size"';
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      ...super.toFirestore(),
      'serial': serial,
      'purchaseDate': purchaseDate,
      'year': year,
      'size': size,
      'model': model,
      'colour': colour,
      'build': build,
      'ram': ram,
      'disk': disk,
      'warranty': warranty,
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
      year: data['year'],
      size: data['size'],
      model: data['model'],
      colour: data['colour'],
      build: data['build'],
      ram: data['ram'],
      disk: data['disk'],
      warranty: data['warranty'],
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
