import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/models/inventory_item.dart';

class FirestoreService {
  late FirebaseFirestore _firestore;

  FirestoreService(FirebaseFirestore firestore) {
    _firestore = firestore;
  }

  deleteItem(String? itemId) async {
    await _firestore.collection('items').doc(itemId).delete();
  }

  borrowItem(InventoryItem item, String? uid) async {
    await _firestore.collection('items').doc(item.firestoreId).update({
      'borrower': uid,
    });
  }
}
