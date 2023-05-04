import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spare_parts/services/firestore_service.dart';

class MetaRepository extends FirestoreService {
  MetaRepository(FirebaseFirestore firestore) : super(firestore);

  Future<Map<String, int>> getItemNameIds() async {
    final metaDoc = await metaCollection.doc('itemNameIds').get();
    if (!metaDoc.exists) return {};

    return Map.fromEntries((metaDoc.data() as Map<String, dynamic>).entries.map(
          (entry) => MapEntry(
            entry.key,
            int.parse(
              entry.value.toString(),
            ),
          ),
        ));
  }
}
