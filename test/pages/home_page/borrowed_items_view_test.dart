import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/borrowed_items_view.dart';
import 'package:spare_parts/services/firestore_service.mocks.dart';
import '../../helpers/mocks/mocks.dart';
import '../../helpers/test_helpers.dart';

class MockUser extends Mock implements User {
  @override
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: '');
}

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  final authMock = MockFirebaseAuth();
  MockFirestoreService firestoreServiceMock = MockFirestoreService();
  final userMock = MockUser();
  const user = CustomUser(uid: 'qwe123');
  final chairItem =
      InventoryItem(id: 'Chair#123', type: 'Chair', borrower: user);
  final deskItem = InventoryItem(id: 'Desk#321', type: 'Desk');

  setUp(() async {
    firestoreServiceMock = MockFirestoreService();
    await firestore
        .collection('items')
        .doc(chairItem.id)
        .set(chairItem.toFirestore());

    await firestore
        .collection('items')
        .doc(deskItem.id)
        .set(deskItem.toFirestore());

    when(userMock.uid).thenReturn(user.uid);
    when(authMock.currentUser).thenReturn(userMock);
  });

  tearDown(() async {
    deleteAllData(firestore);
  });

  testWidgets(
    'Displays only items that were borrowed by the current user',
    (WidgetTester tester) async {
      await pumpPage(
        Scaffold(body: BorrowedItemsView()),
        tester,
        firestore: firestore,
        auth: authMock,
      );

      expect(find.text(chairItem.id), findsOneWidget);
      expect(find.text(deskItem.id), findsNothing);
    },
  );

  testWidgets(
    'Should not display the "borrow" action for an already borrowed item',
    (WidgetTester tester) async {
      await pumpPage(
        Scaffold(body: BorrowedItemsView()),
        tester,
        firestore: firestore,
        auth: authMock,
      );

      final chairListItem = find.ancestor(
        of: find.text(chairItem.id),
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
      await pumpPage(
        Scaffold(body: BorrowedItemsView()),
        tester,
        firestore: firestore,
        auth: authMock,
      );

      final chairListItem = find.ancestor(
        of: find.text(chairItem.id),
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

      expect(find.text(chairItem.id), findsNothing);
      expect(find.text('Item has been successfully released'), findsOneWidget);
    },
  );

  testWidgets(
    'Displays error message if error occurs',
    (WidgetTester tester) async {
      const String errorMessage = 'Something went wrong';
      when(
        firestoreServiceMock.getItemsStream(
          whereBorrowerIs: anyNamed('whereBorrowerIs'),
        ),
      ).thenAnswer(
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
  );
}
