import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/models/inventory_item.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

  testWidgets(
    'Displays name of item',
    (WidgetTester tester) async {
      final testItem = InventoryItem(id: '#re4123', type: 'Chair');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<FirebaseFirestore>(create: (context) => firestore),
            Provider<UserRole>(create: (context) => UserRole.user)
          ],
          child: MaterialApp(
            home: Scaffold(body: InventoryListItem(item: testItem)),
          ),
        ),
      );

      expect(find.text(testItem.id), findsOneWidget);
    },
  );
}
