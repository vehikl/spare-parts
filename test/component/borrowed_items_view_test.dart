import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/borrowed_items_view.dart';
import 'package:spare_parts/services/firestore_service.dart';
import '../test_helpers.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Stream<List<InventoryItem>> getItemsStream({
    String? whereBorrowerIs,
    bool? withNoBorrower,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #getItemsStream,
          [],
          {#whereBorrowerIs: whereBorrowerIs, #withNoBorrower: withNoBorrower},
        ),
        returnValue: Stream<List<InventoryItem>>.empty(),
      );
}

class MockUser extends Mock implements User {
  @override
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: '');
}

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  final authMock = MockFirebaseAuth();
  final firestoreServiceMock = MockFirestoreService();
  final userMock = MockUser();
  const uid = 'qwe123';

  setUp(() async {
    await firestore.collection('items').doc().set({
      'id': 'Chair#123',
      'type': 'Chair',
      'borrower': uid,
    });

    await firestore.collection('items').doc().set({
      'id': 'Desk#321',
      'type': 'Desk',
      'borrower': null,
    });

    when(userMock.uid).thenReturn(uid);
  });

  tearDown(() async {
    final items = await firestore.collection('items').get();
    for (final doc in items.docs) {
      await doc.reference.delete();
    }
  });

  testWidgets(
    'Displays only items that were borrowed the current user',
    (WidgetTester tester) async {
      when(authMock.currentUser).thenReturn(userMock);

      await pumpPage(
        Scaffold(body: BorrowedItemsView()),
        tester,
        firestore: firestore,
        auth: authMock,
      );

      expect(find.text('Chair#123'), findsOneWidget);
      expect(find.text('Desk#321'), findsNothing);
    },
  );

  testWidgets(
    'Should not display the "borrow" action for an already borrowed item',
    (WidgetTester tester) async {
      when(authMock.currentUser).thenReturn(userMock);

      await pumpPage(
        Scaffold(body: BorrowedItemsView()),
        tester,
        firestore: firestore,
        auth: authMock,
      );

      final chairListItem = find.ancestor(
        of: find.text('Chair#123'),
        matching: find.byType(ListTile),
      );
      final optionsButton = find.descendant(
        of: chairListItem,
        matching: find.byIcon(Icons.more_vert),
      );

      await tester.tap(optionsButton);
      await tester.pumpAndSettle();

      expect(find.text('Borrow'), findsNothing);
    },
  );

  testWidgets(
    'User can release an item from the list',
    (WidgetTester tester) async {
      when(authMock.currentUser).thenReturn(userMock);

      await pumpPage(
        Scaffold(body: BorrowedItemsView()),
        tester,
        firestore: firestore,
        auth: authMock,
      );

      final chairListItem = find.ancestor(
        of: find.text('Chair#123'),
        matching: find.byType(ListTile),
      );
      final optionsButton = find.descendant(
        of: chairListItem,
        matching: find.byIcon(Icons.more_vert),
      );

      await tester.tap(optionsButton);
      await tester.pumpAndSettle();

      final releaseButton = find.text('Release');
      await tester.tap(releaseButton);
      await tester.pumpAndSettle();

      expect(find.text('Chair#123'), findsNothing);
      expect(find.text('Item has been successfully released'), findsOneWidget);
    },
  );

  testWidgets(
    'Displays error message if error occurs',
    (WidgetTester tester) async {
      const String errorMessage = 'Something went wrong';
      when(firestoreServiceMock.getItemsStream()).thenAnswer(
        (_) => Stream<List<InventoryItem>>.error(Exception(errorMessage)),
      );

      await pumpPage(
        Scaffold(body: BorrowedItemsView()),
        tester,
        auth: authMock,
        firestoreService: firestoreServiceMock,
      );

      expect(find.textContaining(errorMessage), findsOneWidget);
    },
    skip: true,
  );
}