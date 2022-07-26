import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/pages/home_page/borrowed_items_view.dart';
import 'package:spare_parts/utilities/constants.dart';

import 'test_helpers.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  final uid = 'qwe123';

  setUp(() async {
    await firestore.collection('items').doc().set({
      'id': 'Chair#123',
      'type': 'Chair',
      'borrowers': [uid]
    });

    await firestore
        .collection('items')
        .doc()
        .set({'id': 'Desk#321', 'type': 'Desk', 'borrowers': []});
  });

  tearDown(() async {
    final items = await firestore.collection('items').get();
    for (final doc in items.docs) {
      await doc.reference.delete();
    }
  });

  testWidgets(
    'Displays only items that were borrowed',
    (WidgetTester tester) async {
      await pumpPage(
        Scaffold(body: BorrowedItemsView()),
        tester,
        firestore: firestore,
      );

      expect(find.text('Chair#123'), findsOneWidget);
    },
  );
}
