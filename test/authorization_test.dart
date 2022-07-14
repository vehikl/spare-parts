import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/home_page.dart';

void main() async {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

  final user = MockUser(
    isAnonymous: false,
    uid: 'someuid',
    email: 'bob@somedomain.com',
    displayName: 'Bob',
    providerData: [
      UserInfo({'role': 'admin'})
    ],
  );
  final auth = MockFirebaseAuth(mockUser: user);
  await auth.signInWithEmailAndPassword(
      email: 'bob@somedomain.com', password: '123456*');
  print(user.displayName);

  Future<void> pumpHomePage(WidgetTester tester) async {
    await tester.pumpWidget(Provider<FirebaseAuth>(
      create: (context) => auth,
      child: Provider<FirebaseFirestore>(
        create: (context) => firestore,
        child: MaterialApp(home: HomePage()),
      ),
    ));

    await tester.idle();
    await tester.pump();
  }

  testWidgets('Shows the add button if the user is an admin',
      (WidgetTester tester) async {
    await pumpHomePage(tester);

    await tester.pumpAndSettle(Duration(seconds: 2));

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Hides the add button if the user is not an admin',
      (WidgetTester tester) async {
    await pumpHomePage(tester);

    expect(find.byIcon(Icons.add), findsNothing);
  });
}
