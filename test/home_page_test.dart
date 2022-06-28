import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/pages/home_page.dart';

void main() {
  late final FakeFirebaseFirestore firestore;

  Future<void> pumpHomePage(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomePage(firestore: firestore),
    ));

    await tester.idle();
    await tester.pump();
  }

  setUpAll(() async {
    firestore = FakeFirebaseFirestore();
    await firestore.collection('Items').doc('Chair').set({'cost': 123});
  });

  testWidgets(
    'Displays a list of inventory items',
    (WidgetTester tester) async {
      await pumpHomePage(tester);

      expect(find.text('Inventory'), findsOneWidget);
      expect(find.text('Chair'), findsOneWidget);
    },
  );

  testWidgets(
    'Adds new item to inventory list',
    (WidgetTester tester) async {
      const itemId = '21DSAdd4';

      await pumpHomePage(tester);

      final fab = find.byIcon(Icons.add);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      final typeInput = find.byType(DropdownButton<String>);
      await tester.tap(typeInput);
      await tester.pumpAndSettle();

      final deskOption = find.text('Desk').first;
      await tester.tap(deskOption);

      final idInput = find.byType(TextField);
      await tester.enterText(idInput, itemId);

      final addButton = find.text('Add');
      await tester.tap(addButton);

      expect(find.text(itemId), findsOneWidget);
    },
  );

  testWidgets(
    'It displays an error if a user tried to add an item with no ID',
    (WidgetTester tester) async {
      await pumpHomePage(tester);

      final fab = find.byIcon(Icons.add);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.text('You must set an ID'), findsNothing);

      final addButton = find.text('Add');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.text('You must set an ID'), findsOneWidget);
    },
  );
}
