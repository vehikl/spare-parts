import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/utilities/constants.dart';

import 'test_helpers.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

  setUp(() async {
    await firestore
        .collection('items')
        .doc()
        .set({'cost': 123, 'id': 'Chair#123', 'type': 'Chair'});
  });

  tearDown(() async {
    final items = await firestore.collection('items').get();
    for (final doc in items.docs) {
      await doc.reference.delete();
    }
  });

  testWidgets(
    'Displays a list of inventory items',
    (WidgetTester tester) async {
      await pumpHomePage(tester, firestore: firestore);

      expect(find.text('Inventory'), findsOneWidget);
      expect(find.text('Chair#123'), findsOneWidget);
    },
  );

  testWidgets(
    'Adds new item to inventory list',
    (WidgetTester tester) async {
      const itemId = '21DSAdd4';

      await pumpHomePage(
        tester,
        userRole: UserRole.admin,
        firestore: firestore,
      );

      final fab = find.byIcon(Icons.add);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      final typeInput = find.byType(DropdownButton<String>);
      await tester.tap(typeInput);
      await tester.pumpAndSettle();

      final deskOption = find.text('Desk').last;
      await tester.tap(deskOption);

      final idInput = find.byType(TextField);
      await tester.enterText(idInput, itemId);

      final addButton = find.text('Save');
      await tester.tap(addButton);

      expect(find.text(itemId), findsOneWidget);
    },
  );

  testWidgets(
    'Edits an inventory item',
    (WidgetTester tester) async {
      const oldItemId = 'Chair#123';
      const newItemId = 'Chair#321';

      await pumpHomePage(
        tester,
        userRole: UserRole.admin,
        firestore: firestore,
      );

      final chairListItem = find.ancestor(
        of: find.text(oldItemId),
        matching: find.byType(ListTile),
      );
      final optionsButton = find.descendant(
        of: chairListItem,
        matching: find.byIcon(Icons.more_vert),
      );

      await tester.tap(optionsButton);
      await tester.pumpAndSettle();

      final editButton = find.text('Edit');
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      final idInput = find.byType(TextField);
      final idInputText = find.descendant(
        of: idInput,
        matching: find.text(oldItemId),
      );
      expect(idInputText, findsOneWidget);
      await tester.enterText(idInput, newItemId);

      final typeInput = find.byType(DropdownButton<String>);
      await tester.tap(typeInput);
      await tester.pumpAndSettle();

      final laptopOption = find.text('Laptop').last;
      await tester.tap(laptopOption);
      await tester.pumpAndSettle();

      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text(newItemId), findsOneWidget);
      expect(find.text(oldItemId), findsNothing);
      expect(find.byIcon(Icons.laptop), findsOneWidget);
    },
  );

  testWidgets(
    'Saves the initial value of the item id if not updated on edit',
    (WidgetTester tester) async {
      const oldItemId = 'Chair#123';

      await pumpHomePage(
        tester,
        userRole: UserRole.admin,
        firestore: firestore,
      );

      final chairListItem = find.ancestor(
        of: find.text(oldItemId),
        matching: find.byType(ListTile),
      );
      final optionsButton = find.descendant(
        of: chairListItem,
        matching: find.byIcon(Icons.more_vert),
      );

      await tester.tap(optionsButton);
      await tester.pumpAndSettle();

      final editButton = find.text('Edit');
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text(oldItemId), findsOneWidget);
      expect(find.byIcon(Icons.chair), findsOneWidget);
    },
  );

  testWidgets(
    'It displays an error if a user tried to add an item with no ID',
    (WidgetTester tester) async {
      await pumpHomePage(
        tester,
        userRole: UserRole.admin,
        firestore: firestore,
      );

      final fab = find.byIcon(Icons.add);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.text('You must set an ID'), findsNothing);

      final addButton = find.text('Save');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.text('You must set an ID'), findsOneWidget);
    },
  );

  testWidgets(
    'Deletes an item from the list',
    (WidgetTester tester) async {
      await pumpHomePage(
        tester,
        userRole: UserRole.admin,
        firestore: firestore,
      );

      final chairListItem = find.ancestor(
        of: find.text('Chair#123'),
        matching: find.byType(ListTile),
      );
      final optionsButton = find.descendant(
        of: chairListItem,
        matching: find.byIcon(Icons.more_vert),
      );

      await tester.tap(optionsButton);
      await tester.pumpAndSettle();

      final deleteButton = find.text('Delete');
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.text('Chair#123'), findsNothing);
    },
  );
}
