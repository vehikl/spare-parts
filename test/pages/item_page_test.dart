import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/event.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/entities/inventory_items/laptop.dart';
import 'package:spare_parts/pages/item_page/item_page.dart';
import 'package:spare_parts/utilities/constants.dart';

import '../helpers/test_helpers.dart';
import '../helpers/tester_extension.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

  setUp(() async {
    await deleteAllData(firestore);
  });

  testWidgets('Displays the name of the item', (WidgetTester tester) async {
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
  });

  testWidgets('Listens for DB changes', (WidgetTester tester) async {
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
  });

  group('when item is Laptop', () {
    final laptop = Laptop(
      id: 'foo',
      name: 'Test Item',
      serial: '145541',
      purchaseDate: DateTime.now(),
      year: 2019,
      size: 15,
      model: 'MacBook Pro',
      colour: 'Space Grey',
      build: '2.3GHz x 4 i7 / 32GB',
      ram: 16,
      disk: '512GB',
      warranty: 'AppleCare+',
    );

    setUp(() async {
      await firestore
          .collection('items')
          .doc(laptop.id)
          .set(laptop.toFirestore());
    });

    tearDown(() async {
      await deleteAllData(firestore);
    });

    testWidgets('Displays Laptop metadata', (WidgetTester tester) async {
      await pumpPage(
        Scaffold(body: ItemPage(itemId: laptop.id)),
        tester,
        firestore: firestore,
      );

      expect(find.text(laptop.serial), findsOneWidget);
      expect(find.text(laptop.formattedPurchaseDate), findsOneWidget);
      expect(find.text(laptop.year.toString()), findsOneWidget);
      expect(find.text(laptop.formattedSize), findsOneWidget);
      expect(find.text(laptop.model!), findsOneWidget);
      expect(find.text(laptop.colour!), findsOneWidget);
      expect(find.text(laptop.build!), findsOneWidget);
      expect(find.text(laptop.ram.toString()), findsOneWidget);
      expect(find.text(laptop.disk!), findsOneWidget);
      expect(find.text(laptop.warranty!), findsOneWidget);
    });

    testWidgets('Saves year information after editing a Laptop',
        (WidgetTester tester) async {
      String newYear = '2020';
      
      await pumpPage(
        Scaffold(body: ItemPage(itemId: laptop.id)),
        tester,
        firestore: firestore,
        userRole: UserRole.admin,
      );

      final optionsButton = find.byIcon(Icons.more_vert);
      await tester.tap(optionsButton);
      await tester.pumpAndSettle();
      final editButton = find.text('Edit');
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      await tester.enterTextByLabel('Year', newYear);

      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text(newYear), findsOneWidget);
    });
  });

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

    testWidgets(
      'Displays events in the history modal',
      (WidgetTester tester) async {
        final testItem = InventoryItem(id: '#re4123', type: 'Chair');
        await firestore
            .collection('items')
            .doc(testItem.id)
            .set(testItem.toFirestore());

        final event = Event(
          issuerId: 'foo',
          issuerName: 'Jonny',
          type: 'Borrow',
          createdAt: DateTime.now(),
        );

        await firestore
            .collection('items')
            .doc(testItem.id)
            .collection('events')
            .add(event.toFirestore());

        await pumpPage(
          Scaffold(body: ItemPage(itemId: testItem.id)),
          tester,
          userRole: UserRole.admin,
          firestore: firestore,
        );

        await tester.pumpAndSettle();

        expect(find.text(event.issuerName), findsOneWidget);
        expect(find.text(event.type), findsOneWidget);
      },
    );
  });
}
