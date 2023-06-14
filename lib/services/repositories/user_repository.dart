import 'package:mockito/annotations.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/services/firestore_service.dart';

@GenerateNiceMocks([MockSpec<UserRepository>()])
class UserRepository extends FirestoreService {
  UserRepository(super.firestore);

  Stream<List<CustomUser>> getAllStream() {
    return usersCollection.snapshots().map((snapshot) => snapshot.docs
        .map((e) => CustomUser.fromFirestore(e.data() as Map<String, dynamic>))
        .toList());
  }

  Future<List<CustomUser>> getAll() async {
    final userSnapshots = await usersCollection.get();
    return userSnapshots.docs
        .map((e) => CustomUser.fromFirestore(e.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(CustomUser user) async {
    await usersCollection.add(user.toFirestore());
  }

  Future<void> update(String originalUid, CustomUser user) async {
    final userDocs = await usersCollection.where('uid', isEqualTo: originalUid).get();
    final userDoc = userDocs.docs.first;
    await userDoc.reference.update(user.toFirestore());
  }

  Future<void> delete(CustomUser user) async {
    final userDocs = await usersCollection.where('uid', isEqualTo: user.uid).get();
    final userDoc = userDocs.docs.first;
    await userDoc.reference.delete();
  }
}
