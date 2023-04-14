import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/dtos/user_dto.dart';
import 'package:spare_parts/services/callable_service.dart';
import 'package:spare_parts/services/callable_service.mocks.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/services/repositories/inventory_item_repository.dart';
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
}) async {
  final mockCallableService = MockCallableService();
  when(mockCallableService.getUsers()).thenAnswer((_) => Future.value([
        UserDto(
          id: 'foo',
          name: 'Foo',
          role: UserRole.admin,
        )
      ]));

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (context) => auth ?? MockFirebaseAuth()),
        Provider<UserRole>(create: (context) => userRole ?? UserRole.user),
        Provider<FirestoreService>(
            create: (context) =>
                firestoreService ??
                FirestoreService(firestore ?? FakeFirebaseFirestore())),
        Provider<InventoryItemRepository>(
            create: (context) =>
                inventoryItemRepository ??
                InventoryItemRepository(firestore ?? FakeFirebaseFirestore())),
        Provider<CallableService>(
            create: (context) => callableService ?? mockCallableService),
      ],
      child: MaterialApp(home: page),
    ),
  );

  await tester.idle();
  await tester.pump();
}

Future<void> deleteAllData(FirebaseFirestore firestore) async {
  final collections = ['borrowingRules', 'items'];

  for (var collection in collections) {
    final items = await firestore.collection(collection).get();
    for (final doc in items.docs) {
      await doc.reference.delete();
    }
  }
}
