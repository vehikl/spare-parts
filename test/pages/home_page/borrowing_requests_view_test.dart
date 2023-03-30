import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/utilities/helpers.dart';
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
  final userMock = MockUser();
  const user = CustomUser(uid: 'qwe123', name: 'John Doe');
  final chairItem =
      InventoryItem(id: 'Chair#123', type: 'Chair', borrower: user);
  final deskItem = InventoryItem(id: 'Desk#321', type: 'Desk');
  final currentUserserBorrowingRequest = BorrowingRequest(
    issuer: BorrowingRequestIssuer.fromCustomUser(user),
    item: BorrowingRequestItem.fromInventoryItem(chairItem),
    createdAt: DateTime.now(),
  );
  final otherUserBorrowingRequest = BorrowingRequest(
    issuer: BorrowingRequestIssuer(id: 'anotherUserId'),
    item: BorrowingRequestItem.fromInventoryItem(deskItem),
  );

  setUp(() async {
    await firestore
        .collection('items')
        .doc(chairItem.id)
        .set(chairItem.toFirestore());

    await firestore
        .collection('items')
        .doc(deskItem.id)
        .set(deskItem.toFirestore());

    await firestore
        .collection('borrowingRequests')
        .add(currentUserserBorrowingRequest.toFirestore());

    await firestore
        .collection('borrowingRequests')
        .add(otherUserBorrowingRequest.toFirestore());

    when(userMock.uid).thenReturn(user.uid);
    when(authMock.currentUser).thenReturn(userMock);
  });

  tearDown(() async {
    deleteAllData(firestore);
  });

  testWidgets(
    'Displays the borrowing requests of the current user',
    (WidgetTester tester) async {
      await pumpPage(
        Scaffold(body: BorrowingRequestsView()),
        tester,
        firestore: firestore,
        auth: authMock,
      );

      expect(find.text(chairItem.id), findsOneWidget);
      expect(
        find.text(formatDate(currentUserserBorrowingRequest.createdAt!)),
        findsOneWidget,
      );
      expect(find.byIcon(itemTypes[chairItem.type]!), findsOneWidget);
    },
  );
}
