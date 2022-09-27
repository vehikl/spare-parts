import 'package:mockito/mockito.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';

class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Stream<List<InventoryItem>> getItemsStream({
    String? whereBorrowerIs,
    bool? withNoBorrower,
    List<String>? whereTypeIn,
    List<String>? whereUsersIdsIn,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #getItemsStream,
          [],
          {
            #whereBorrowerIs: whereBorrowerIs,
            #withNoBorrower: withNoBorrower,
            #whereTypeIn: whereTypeIn,
            #whereUsersIdsIn: whereUsersIdsIn,
          },
        ),
        returnValue: Stream<List<InventoryItem>>.empty(),
      );
}
