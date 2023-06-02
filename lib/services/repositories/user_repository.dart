import 'package:mockito/annotations.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/services/firestore_service.dart';

@GenerateNiceMocks([MockSpec<UserRepository>()])
class UserRepository extends FirestoreService {
  UserRepository(super.firestore);

  Future<List<CustomUser>> getAll() async {
    final userSnapshots = await usersCollection.get();
    return userSnapshots.docs
        .map((e) => CustomUser.fromFirestore(e.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(CustomUser user) async {
    await usersCollection.add(user.toFirestore());
  }

  Stream<List<CustomUser>> getAllStream() {
    return usersCollection.snapshots().map((snapshot) => snapshot.docs
        .map((e) => CustomUser.fromFirestore(e.data() as Map<String, dynamic>))
        .toList());
  }
}
