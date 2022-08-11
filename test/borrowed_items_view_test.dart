import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/pages/home_page/borrowed_items_view.dart';
import 'test_helpers.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {
  @override
  String get uid =>
      super.noSuchMethod(Invocation.getter(#uid), returnValue: '');
}

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  final authMock = MockFirebaseAuth();
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
}
