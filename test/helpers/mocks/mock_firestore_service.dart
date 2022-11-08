import 'package:mockito/mockito.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';

class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Stream<List<InventoryItem>> getItemsStream({
    bool? withNoBorrower,
    String? whereBorrowerIs,
    List<String>? whereBorrowerIn,
    List<String>? whereTypeIn,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #getItemsStream,
          [],
          {
            #withNoBorrower: withNoBorrower,
            #whereBorrowerIs: whereBorrowerIs,
            #whereBorrowerIn: whereBorrowerIn,
            #whereTypeIn: whereTypeIn,
          },
        ),
        returnValue: Stream<List<InventoryItem>>.empty(),
      );
}
