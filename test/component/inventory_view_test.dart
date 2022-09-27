import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/home_page.dart';
import 'package:spare_parts/pages/home_page/inventory_view/inventory_view.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

import '../helpers/mocks/mocks.dart';
import '../helpers/test_helpers.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

  setUp(() async {
    final testItem = InventoryItem(id: 'Chair#123', type: 'Chair');
    await firestore.collection('items').doc().set(testItem.toFirestore());
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
      await pumpPage(Scaffold(body: InventoryView()), tester,
          firestore: firestore);

      expect(find.text('Chair#123'), findsOneWidget);
    },
  );

  group('Adding an item', () {
    testWidgets(
      'Adds new item to inventory list',
      (WidgetTester tester) async {
        const itemId = '21DSAdd4';

        await pumpPage(HomePage(), tester,
            userRole: UserRole.admin, firestore: firestore);

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
      'Displays an error if no ID provided',
      (WidgetTester tester) async {
        await pumpPage(HomePage(), tester,
            userRole: UserRole.admin, firestore: firestore);

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
  });

  group('Editing an item', () {
    testWidgets(
      'Edits an inventory item',
      (WidgetTester tester) async {
        const oldItemId = 'Chair#123';
        const newItemId = 'Chair#321';

        await pumpPage(Scaffold(body: InventoryView()), tester,
            userRole: UserRole.admin, firestore: firestore);

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
        final newItemTypeIcon = find.descendant(
          of: find.byType(InventoryListItem),
          matching: find.byIcon(Icons.laptop),
        );
        expect(newItemTypeIcon, findsOneWidget);
      },
    );

    testWidgets(
      'Saves the initial value of the item id if not updated',
      (WidgetTester tester) async {
        const oldItemId = 'Chair#123';

        await pumpPage(Scaffold(body: InventoryView()), tester,
            userRole: UserRole.admin, firestore: firestore);

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
        final itemTypeIcon = find.descendant(
          of: find.byType(InventoryListItem),
          matching: find.byIcon(Icons.chair),
        );
        expect(itemTypeIcon, findsOneWidget);
      },
    );
  });

  group('Deleting an item', () {
    testWidgets(
      'Deletes an item from the list',
      (WidgetTester tester) async {
        await pumpPage(Scaffold(body: InventoryView()), tester,
            userRole: UserRole.admin, firestore: firestore);

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
  });

  testWidgets(
    'User can borrow an item from the list',
    (WidgetTester tester) async {
      final authMock = MockFirebaseAuth();
      final userMock = MockUser();

      when(authMock.currentUser).thenReturn(userMock);
      when(userMock.uid).thenReturn('foo');

      await pumpPage(
        Scaffold(body: InventoryView()),
        tester,
        userRole: UserRole.user,
        firestore: firestore,
        auth: authMock,
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

      final borrowButton = find.text('Borrow');
      await tester.tap(borrowButton);
      await tester.pumpAndSettle();

      expect(find.text('Chair#123'), findsNothing);
      expect(find.text('Item has been successfully borrowed'), findsOneWidget);
    },
  );

  group('Filtering items', () {
    group('By Type', () {
      testWidgets(
        'Shows only items of the selected types',
        (WidgetTester tester) async {
          final deskItem = InventoryItem(id: 'Desk#123', type: 'Desk');
          final monitorItem = InventoryItem(id: 'Monitor#123', type: 'Monitor');
          await firestore.collection('items').doc().set(deskItem.toFirestore());  
          await firestore.collection('items').doc().set(monitorItem.toFirestore());  

          await pumpPage(
            Scaffold(body: InventoryView()),
            tester,
            userRole: UserRole.admin,
            firestore: firestore,
          );

          expect(find.text('Chair#123'), findsOneWidget);
          expect(find.text(deskItem.id), findsOneWidget);
          expect(find.text(monitorItem.id), findsOneWidget);

          final deskFilterChip = find.ancestor(
            of: find.byIcon(inventoryItems['Desk']!),
            matching: find.byType(FilterChip),
          );
          final chairFilterChip = find.ancestor(
            of: find.byIcon(inventoryItems['Chair']!),
            matching: find.byType(FilterChip),
          );

          await tester.tap(deskFilterChip);
          await tester.pumpAndSettle();
          await tester.tap(chairFilterChip);
          await tester.pumpAndSettle();

          expect(find.text('Chair#123'), findsOneWidget);
          expect(find.text(deskItem.id), findsOneWidget);
          expect(find.text(monitorItem.id), findsNothing);
        },
      );
    });
  });
}
