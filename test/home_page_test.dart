import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/pages/home_page.dart';

void main() {
  testWidgets(
    'Displays a list of inventory items',
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
    'Adds new item to inventory list',
    (WidgetTester tester) async {
      final firestore = FakeFirebaseFirestore();
      const itemId = '21DSAdd4';

      await tester.pumpWidget(MaterialApp(
        home: HomePage(firestore: firestore),
      ));

      final fab = find.byIcon(Icons.add);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      // tap on the dropdown and wait for the options to show up
      final typeInput = find.byType(DropdownButton<String>);
      await tester.tap(typeInput);
      await tester.pumpAndSettle();

      // pick the 'Desk' option
      final deskOption = find.text('Desk').first;
      await tester.tap(deskOption);

      final idInput = find.byType(TextField);
      await tester.enterText(idInput, itemId);

      final addButton = find.text('Add');
      await tester.tap(addButton);

      expect(find.text(itemId), findsOneWidget);
    },
  );
}
