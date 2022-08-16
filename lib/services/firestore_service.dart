import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/models/inventory_item.dart';

class FirestoreService {
  late FirebaseFirestore _firestore;

  FirestoreService(FirebaseFirestore firestore) {
    _firestore = firestore;
  }

  DocumentReference getItemDocumentReference(String? itemId) {
    return _firestore.collection('items').doc(itemId);
  }

  deleteItem(String? itemId) async {
    await getItemDocumentReference(itemId).delete();
  }

  borrowItem(InventoryItem item, String? uid) async {
    await getItemDocumentReference(item.firestoreId).update({
      'borrower': uid,
    });
  }

  releaseItem(InventoryItem item) async {
    await getItemDocumentReference(item.firestoreId).update({'borrower': null});
  }
}
