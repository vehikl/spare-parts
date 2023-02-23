import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/inventory_view/inventory_view.dart';
import 'package:spare_parts/pages/item_page.dart';

import '../../helpers/test_helpers.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

  testWidgets(
    'Displays the name of the item',
    (WidgetTester tester) async {
      var testItemName = 'Test Item';

      await pumpPage(
        Scaffold(
          body: ItemPage(
            item: InventoryItem(
              id: 'foo',
              type: 'Chair',
              name: testItemName,
            ),
          ),
        ),
        tester,
        firestore: firestore,
      );

      expect(
        find.descendant(
          of: find.byType(Card),
          matching: find.text(testItemName),
        ),
        findsOneWidget,
      );
    },
  );
}
