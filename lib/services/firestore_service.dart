import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  late FirebaseFirestore _firestore;

  FirestoreService(FirebaseFirestore firestore) {
    _firestore = firestore;
  }

  deleteItem(String? itemId) async {
    await _firestore.collection('items').doc(itemId).delete();
  }
}
