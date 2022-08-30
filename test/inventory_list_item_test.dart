import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/models/inventory_item.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

import 'test_helpers.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  testWidgets(
    'Displays name of item',
    (WidgetTester tester) async {
      final testItem = InventoryItem(id: '#re4123', type: 'Chair');

      await pumpPage(Scaffold(body: InventoryListItem(item: testItem)), tester);

      expect(find.text(testItem.id), findsOneWidget);
    },
  );

  testWidgets('Displays a modal with item history for admin user',
      (WidgetTester tester) async {
    final testItem = InventoryItem(id: '#re4123', type: 'Chair');

    await pumpPage(Scaffold(body: InventoryListItem(item: testItem)), tester,
        userRole: UserRole.admin);

    final invetoryItemElement = find.ancestor(
      of: find.text('#re4123'),
      matching: find.byType(ListTile),
    );

    await tester.tap(invetoryItemElement);
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
  });

  testWidgets('Does not display a modal when a non-admin user clicks an item',
      (WidgetTester tester) async {
    final testItem = InventoryItem(id: '#re4123', type: 'Chair');

    await pumpPage(Scaffold(body: InventoryListItem(item: testItem)), tester);

    final invetoryItemElement = find.ancestor(
      of: find.text('#re4123'),
      matching: find.byType(ListTile),
    );

    await tester.tap(invetoryItemElement);
    await tester.pumpAndSettle();

    expect(find.text('History'), findsNothing);
  });

  testWidgets('Displays events in the history modal',
      (WidgetTester tester) async {
    await firestore.collection('items').doc().set({
      'id': 'Chair#123',
      'type': 'Chair',
      'borrower': null,
    });

    await firestore
        .collection('items')
        .doc('#re1234')
        .collection('events')
        .doc()
        .set({
      'issuerName': 'Jonny',
      'type': 'borrow',
    });

    final testItem = InventoryItem(id: '#re4123', type: 'Chair');
    await pumpPage(Scaffold(body: InventoryListItem(item: testItem)), tester,
        userRole: UserRole.admin);

    final invetoryItemElement = find.ancestor(
      of: find.text('#re4123'),
      matching: find.byType(ListTile),
    );

    await tester.tap(invetoryItemElement);
    await tester.pumpAndSettle();

    expect(find.text('Jonny'), findsOneWidget);
  });
}
