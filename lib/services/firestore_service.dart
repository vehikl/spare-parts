import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:spare_parts/entities/event.dart';

@GenerateNiceMocks([MockSpec<FirestoreService>()])
class FirestoreService {
  late FirebaseFirestore _firestore;

  FirestoreService(FirebaseFirestore firestore) {
    _firestore = firestore;
  }

  CollectionReference get itemsCollection => _firestore.collection('items');
  CollectionReference get borrowingRulesCollection =>
      _firestore.collection('borrowingRules');

  CollectionReference get borrowingRequestsCollection =>
      _firestore.collection('borrowingRequests');
  
  CollectionReference get metaCollection => _firestore.collection('meta');

  CollectionReference get usersCollection => _firestore.collection('users');


  Stream<List<Event>> getEventsStream(String? inventoryItemId) {
    return itemsCollection
        .doc(inventoryItemId)
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  Future<void> addEvent(String inventoryItemId, Event event) async {
    await itemsCollection
        .doc(inventoryItemId)
        .collection('events')
        .add(event.toFirestore());
  }
}
