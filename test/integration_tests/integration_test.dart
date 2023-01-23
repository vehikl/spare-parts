import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/home_page.dart';
import 'package:spare_parts/utilities/constants.dart';

import '../helpers/mocks/mocks.dart';
import '../helpers/test_helpers.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  final testItem = InventoryItem(id: 'Chair#123', type: 'Chair');

  setUp(() async {
    await firestore
        .collection('items')
        .doc(testItem.id)
        .set(testItem.toFirestore());
  });

  tearDown(() async {
    final items = await firestore.collection('items').get();
    for (final doc in items.docs) {
      await doc.reference.delete();
    }
  });

  testWidgets(
    'Displays events after borrowing and releasing',
    (WidgetTester tester) async {
      final authMock = MockFirebaseAuth();
      final userMock = MockUser();
      const userName = 'name';

      when(authMock.currentUser).thenReturn(userMock);
      when(userMock.uid).thenReturn('foo');
      when(userMock.displayName).thenReturn(userName);

      await pumpPage(
        HomePage(),
        tester,
        userRole: UserRole.admin,
        firestore: firestore,
        auth: authMock,
      );

      var chairListItem = find.ancestor(
        of: find.text(testItem.id),
        matching: find.byType(ListTile),
      );
      var optionsButton = find.descendant(
        of: chairListItem,
        matching: find.byIcon(Icons.more_vert),
      );

      await tester.tap(optionsButton);
      await tester.pumpAndSettle();

      final borrowButton = find.text('Borrow');
      await tester.tap(borrowButton);
      await tester.pumpAndSettle();

      final borrowViewButton = find.byIcon(Icons.backpack_outlined);
      await tester.tap(borrowViewButton);
      await tester.pumpAndSettle();

      chairListItem = find.ancestor(
        of: find.text(testItem.id),
        matching: find.byType(ListTile),
      );
      optionsButton = find.descendant(
        of: chairListItem,
        matching: find.byIcon(Icons.more_vert),
      );

      await tester.tap(optionsButton);
      await tester.pumpAndSettle();

      final releaseButton = find.text('Release');
      await tester.tap(releaseButton);
      await tester.pumpAndSettle();

      final inventoryViewButton = find.byIcon(Icons.home);
      await tester.tap(inventoryViewButton);
      await tester.pumpAndSettle();

      final invetoryItemElement = find.ancestor(
        of: find.text(testItem.id),
        matching: find.byType(ListTile),
      );

      await tester.tap(invetoryItemElement);
      await tester.pumpAndSettle();

      expect(find.text('Borrow'), findsOneWidget);
      expect(find.text('Release'), findsOneWidget);
      expect(find.text(userName), findsNWidgets(2));
    },
  );
}
