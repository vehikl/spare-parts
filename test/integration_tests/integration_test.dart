import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/home_page.dart';
import 'package:spare_parts/utilities/constants.dart';

import '../helpers/mocks/mocks.dart';
import '../helpers/test_helpers.dart';
import '../helpers/tester_extension.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  final testItem = InventoryItem(id: 'Chair#123', type: 'Chair');
  final authMock = MockFirebaseAuth();
  final userMock = MockUser();
  const userName = 'name';

  setUp(() async {
    await firestore
        .collection('items')
        .doc(testItem.id)
        .set(testItem.toFirestore());

    when(authMock.currentUser).thenReturn(userMock);
    when(userMock.uid).thenReturn('foo');
    when(userMock.displayName).thenReturn(userName);
  });

  tearDown(() async {
    await deleteAllData(firestore);
  });

  testWidgets(
    'Displays events after borrowing and releasing',
    (WidgetTester tester) async {
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

      final inventoryViewButton = find.byIcon(Icons.home_outlined);
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

  testWidgets(
    'Displays an "Create" event after adding a new item',
    (WidgetTester tester) async {
      const deskName = 'Desk#123';

      await pumpPage(
        HomePage(),
        tester,
        userRole: UserRole.admin,
        firestore: firestore,
        auth: authMock,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterTextByLabel('Name', deskName);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(deskName));
      await tester.pumpAndSettle();

      expect(find.text('Create'), findsOneWidget);
      expect(find.text(userName), findsOneWidget);
    },
  );

  testWidgets(
    'Displays an "Update" event after updating an item',
    (WidgetTester tester) async {
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

      final editButton = find.text('Edit');
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      const newName = 'NewName';
      await tester.enterTextByLabel('Name', newName);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(newName));
      await tester.pumpAndSettle();

      expect(find.text('Update'), findsOneWidget);
      expect(find.text(userName), findsOneWidget);
    },
  );
}
