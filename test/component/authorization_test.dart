import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/pages/home_page/home_page.dart';
import 'package:spare_parts/utilities/constants.dart';

import '../test_helpers.dart';

void main() async {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

  await firestore
      .collection('items')
      .doc()
      .set({'cost': 123, 'id': 'Chair#123', 'type': 'Chair'});

  testWidgets('Shows the add button if the user is an admin',
      (WidgetTester tester) async {
    await pumpPage(HomePage(), tester,
        userRole: UserRole.admin, firestore: firestore);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('Hides the add button if the user is not an admin',
      (WidgetTester tester) async {
    await pumpPage(HomePage(), tester, firestore: firestore);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsNothing);
  });
}
