import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

Future<void> pumpPage(
  Widget page,
  WidgetTester tester, {
  UserRole? userRole,
  FirebaseAuth? auth,
  FirebaseFirestore? firestore,
  FirestoreService? firestoreService,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (context) => auth ?? MockFirebaseAuth()),
        Provider<UserRole>(create: (context) => userRole ?? UserRole.user),
        Provider<FirestoreService>(create: (context) => firestoreService ?? FirestoreService(firestore ?? FakeFirebaseFirestore()))
      ],
      child: MaterialApp(home: page),
    ),
  );

  await tester.idle();
  await tester.pump();
}
