import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/item_page/item_page.dart';
import 'package:spare_parts/utilities/constants.dart';

import '../../helpers/test_helpers.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

  testWidgets(
    'Displays the name of the item',
    (WidgetTester tester) async {
      final testItem = InventoryItem(
        id: 'foo',
        type: 'Chair',
        name: 'Test Item',
      );

      await firestore
          .collection('items')
          .doc(testItem.id)
          .set(testItem.toFirestore());

      await pumpPage(
        Scaffold(
          body: ItemPage(itemId: testItem.id),
        ),
        tester,
        firestore: firestore,
      );

      expect(
        find.descendant(
          of: find.byType(Card),
          matching: find.text(testItem.name),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Listens for DB changes',
    (WidgetTester tester) async {
      final testItem = InventoryItem(
        id: 'foo',
        type: 'Chair',
        name: 'Test Item',
      );

      await firestore
          .collection('items')
          .doc(testItem.id)
          .set(testItem.toFirestore());

      await pumpPage(
        Scaffold(body: ItemPage(itemId: testItem.id)),
        tester,
        firestore: firestore,
      );

      expect(
        find.descendant(
          of: find.byType(Card),
          matching: find.text(testItem.name),
        ),
        findsOneWidget,
      );

      testItem.name = 'New Name';

      await firestore
          .collection('items')
          .doc(testItem.id)
          .set(testItem.toFirestore());

      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(Card),
          matching: find.text(testItem.name),
        ),
        findsOneWidget,
      );
    },
  );

  group('item event history', () {
    testWidgets(
        'Does not display inventory item event history for non-admin user',
        (WidgetTester tester) async {
      final testItem = InventoryItem(id: '#re4123', type: 'Chair');
      await firestore
          .collection('items')
          .doc(testItem.id)
          .set(testItem.toFirestore());

      await pumpPage(
        Scaffold(body: ItemPage(itemId: testItem.id)),
        tester,
        userRole: UserRole.user,
        firestore: firestore,
      );

      expect(find.textContaining('History'), findsNothing);
    });

    testWidgets('Displays inventory item event history for admin user',
        (WidgetTester tester) async {
      final testItem = InventoryItem(id: '#re4123', type: 'Chair');
      await firestore
          .collection('items')
          .doc(testItem.id)
          .set(testItem.toFirestore());

      await pumpPage(
        Scaffold(body: ItemPage(itemId: testItem.id)),
        tester,
        userRole: UserRole.admin,
        firestore: firestore,
      );

      expect(find.textContaining('History'), findsOneWidget);
    });
  });
}
