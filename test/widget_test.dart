import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/home_page.dart';
import 'package:spare_parts/inventory_list_item.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  testWidgets(
    'HomePage displays a list of inventory items',
    (WidgetTester tester) async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('Items').doc('Chair').set({'cost': 123});

      await tester.pumpWidget(MaterialApp(
        home: HomePage(firestore: firestore),
      ));

      await tester.idle();
      await tester.pump();

      expect(find.text('Inventory'), findsOneWidget);
      expect(find.text('Chair'), findsOneWidget);
    },
  );

  testWidgets(
    'Displays name of item',
    (WidgetTester tester) async {
      const testItem = {'id': 'Chair'};

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InventoryListItem(item: testItem)),
        ),
      );

      expect(find.text(testItem['id']!), findsOneWidget);
    },
  );
}
