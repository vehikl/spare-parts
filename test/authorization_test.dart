import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/constants.dart';
import 'package:spare_parts/pages/home_page.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() async {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();

  await firestore
      .collection('items')
      .doc()
      .set({'cost': 123, 'id': 'Chair#123', 'type': 'Chair'});

  Future<void> pumpHomePage(WidgetTester tester, { UserRole? userRole }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<FirebaseAuth>(create: (context) => auth),
          Provider<FirebaseFirestore>(create: (context) => firestore),
          Provider<UserRole>(create: (context) => userRole ?? UserRole.user)
        ],
        child: MaterialApp(home: HomePage()),
      ),
    );

    await tester.idle();
    await tester.pump();
  }

  testWidgets('Shows the add button if the user is an admin',
      (WidgetTester tester) async {
    await pumpHomePage(tester, userRole: UserRole.admin);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('Hides the add button if the user is not an admin',
      (WidgetTester tester) async {
    await pumpHomePage(tester);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsNothing);
    expect(find.byIcon(Icons.more_vert), findsNothing);
  });
}
