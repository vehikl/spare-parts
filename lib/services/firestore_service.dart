import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<FirestoreService>()])
class FirestoreService {
  late FirebaseFirestore _firestore;

  FirestoreService(FirebaseFirestore firestore) {
    _firestore = firestore;
  }

  CollectionReference<Map<String, dynamic>> get itemsCollection => _firestore.collection('items');
  CollectionReference get borrowingRulesCollection =>
      _firestore.collection('borrowingRules');

  CollectionReference get borrowingRequestsCollection =>
      _firestore.collection('borrowingRequests');
  
  CollectionReference get metaCollection => _firestore.collection('meta');

  CollectionReference get usersCollection => _firestore.collection('users');

  WriteBatch createBatch() {
    return _firestore.batch();
  }

  void runTransaction(TransactionHandler transactionHandler) {
    _firestore.runTransaction(transactionHandler);
  }
}
