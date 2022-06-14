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
}