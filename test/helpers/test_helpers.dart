import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/dtos/user_dto.dart';
import 'package:spare_parts/repository_registrant.dart';
import 'package:spare_parts/services/callable_service.dart';
import 'package:spare_parts/services/callable_service.mocks.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/services/repositories/repositories.dart';
import 'package:spare_parts/utilities/constants.dart';

import 'mocks/mocks.dart';

Future<void> pumpPage(
  Widget page,
  WidgetTester tester, {
  UserRole? userRole,
  FirebaseAuth? auth,
  FirebaseFirestore? firestore,
  FirestoreService? firestoreService,
  InventoryItemRepository? inventoryItemRepository,
  CallableService? callableService,
  UserRepository? userRepository,
}) async {
  final mockCallableService = MockCallableService();
  final firestoreInstance = firestore ?? FakeFirebaseFirestore();
  final authInstance = auth ?? createAuth();

  when(mockCallableService.getUsers()).thenAnswer((_) =>
      Future.value([UserDto(id: 'foo', name: 'Foo', role: UserRole.admin)]));

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (context) => authInstance),
        Provider<UserRole>(create: (context) => userRole ?? UserRole.user),
        Provider<FirestoreService>(
            create: (_) =>
                firestoreService ?? FirestoreService(firestoreInstance)),
        Provider<CallableService>(
            create: (_) => callableService ?? mockCallableService),
        Provider<EventRepository>(
            create: (_) => EventRepository(firestoreInstance, authInstance)),
      ],
      child: RepositoryRegistrant(
        firestore: firestoreInstance,
        inventoryItemRepository: inventoryItemRepository,
        userRepository: userRepository,
        child: MaterialApp(home: page),
      ),
    ),
  );

  await tester.idle();
  await tester.pump();
}

MockFirebaseAuth createAuth({
  String userName = 'Jane Doe',
  String uid = 'foo-bar-baz',
}) {
  final authMock = MockFirebaseAuth();
  final userMock = MockUser();

  when(authMock.currentUser).thenReturn(userMock);
  when(userMock.uid).thenReturn(uid);
  when(userMock.displayName).thenReturn(userName);
  return authMock;
}

Future<void> deleteAllData(FirebaseFirestore firestore) async {
  final collections = ['borrowingRules', 'items', 'users'];

  for (var collection in collections) {
    final items = await firestore.collection(collection).get();
    for (final doc in items.docs) {
      await doc.reference.delete();
    }
  }
}
