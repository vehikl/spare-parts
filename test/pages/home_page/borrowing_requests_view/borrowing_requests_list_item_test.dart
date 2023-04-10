import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/entities/borrowing_response.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view/borrowing_request_list_item.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/utilities/helpers.dart';

import '../../../helpers/mocks/mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('Borrowing Request List Item', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final authMock = MockFirebaseAuth();
    final userMock = MockUser();

    const user = CustomUser(uid: 'qwe123', name: 'John Doe');

    final chairItem = InventoryItem(id: 'Chair#123', type: 'Chair');
    final deskItem = InventoryItem(id: 'Desk#321', type: 'Desk');

    final chairBorrowingRequest = BorrowingRequest(
      issuer: user,
      item: BorrowingRequestItem.fromInventoryItem(chairItem),
      createdAt: DateTime.now(),
    );
    final otherIssuer = CustomUser(uid: 'anotherUserId', name: 'Jane Doe');
    final deskBorrowingRequest = BorrowingRequest(
      issuer: otherIssuer,
      item: BorrowingRequestItem.fromInventoryItem(deskItem),
    );

    setUpAll(() async {
      await firestore
          .collection('items')
          .doc(chairItem.id)
          .set(chairItem.toFirestore());

      await firestore
          .collection('items')
          .doc(deskItem.id)
          .set(deskItem.toFirestore());

      final chairBorrowingRequestRef = await firestore
          .collection('borrowingRequests')
          .add(chairBorrowingRequest.toFirestore());
      chairBorrowingRequest.id = chairBorrowingRequestRef.id;

      await firestore
          .collection('borrowingRequests')
          .add(deskBorrowingRequest.toFirestore());

      when(userMock.uid).thenReturn(user.uid);
      when(authMock.currentUser).thenReturn(userMock);
    });

    group('for regular users', () {
      testWidgets('displays the date and item (id and type)',
          (WidgetTester tester) async {
        await pumpPage(
          Scaffold(
            body: BorrowingRequestListItem(
              borrowingRequest: chairBorrowingRequest,
            ),
          ),
          tester,
          firestore: firestore,
          auth: authMock,
        );

        expect(find.text(chairItem.id), findsOneWidget);
        expect(find.byIcon(itemTypes[chairItem.type]!), findsOneWidget);
        expect(
          find.textContaining(formatDate(chairBorrowingRequest.createdAt!)),
          findsOneWidget,
        );

        expect(find.textContaining(user.name!), findsNothing);
      });

      testWidgets('does not display the issuer or action buttons',
          (WidgetTester tester) async {
        await pumpPage(
          Scaffold(
            body: BorrowingRequestListItem(
              borrowingRequest: chairBorrowingRequest,
            ),
          ),
          tester,
          firestore: firestore,
          auth: authMock,
        );

        expect(
          find.textContaining(chairBorrowingRequest.issuer.name!),
          findsNothing,
        );
        expect(find.byIcon(Icons.more_vert), findsNothing);
      });

      testWidgets('shows the decision maker once the request was approved',
          (WidgetTester tester) async {
        final approvedRequest = BorrowingRequest(
          issuer: user,
          item: BorrowingRequestItem.fromInventoryItem(chairItem),
          createdAt: DateTime.now(),
          response: BorrowingResponse(approved: true, decisionMaker: user),
        );

        await pumpPage(
          Scaffold(
              body: BorrowingRequestListItem(
            borrowingRequest: approvedRequest,
          )),
          tester,
          firestore: firestore,
          auth: authMock,
        );
        expect(find.text('Approved by ${user.name}'), findsOneWidget);
      });

      testWidgets('shows the decision maker once the request was denied',
          (WidgetTester tester) async {
        final deniedRequest = BorrowingRequest(
          issuer: user,
          item: BorrowingRequestItem.fromInventoryItem(chairItem),
          createdAt: DateTime.now(),
          response: BorrowingResponse(approved: false, decisionMaker: user),
        );

        await pumpPage(
          Scaffold(
              body: BorrowingRequestListItem(borrowingRequest: deniedRequest)),
          tester,
          firestore: firestore,
          auth: authMock,
        );
        expect(find.text('Denied by ${user.name}'), findsOneWidget);
      });
    });

    group('for admins', () {
      testWidgets(
        'displays the issuer',
        (WidgetTester tester) async {
          await pumpPage(
            Scaffold(
              body: BorrowingRequestListItem(
                borrowingRequest: chairBorrowingRequest,
              ),
            ),
            tester,
            firestore: firestore,
            auth: authMock,
            userRole: UserRole.admin,
          );

          expect(
            find.textContaining(chairBorrowingRequest.issuer.name!),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'allows accepting the request',
        (WidgetTester tester) async {
          await pumpPage(
            Scaffold(
              body: BorrowingRequestListItem(
                borrowingRequest: chairBorrowingRequest,
              ),
            ),
            tester,
            firestore: firestore,
            auth: authMock,
            userRole: UserRole.admin,
          );

          final optionsButton = find.byIcon(Icons.more_vert);
          await tester.tap(optionsButton);
          await tester.pumpAndSettle();

          final approveButton = find.text('Approve');
          await tester.tap(approveButton);
          await tester.pumpAndSettle();

          final newChairItemDoc =
              await firestore.collection('items').doc(chairItem.id).get();
          final newChairItem = InventoryItem.fromFirestore(newChairItemDoc);
          expect(newChairItem.borrower, isNotNull);
          expect(newChairItem.borrower!.uid, user.uid);

          final newChairBorrowingRequestDoc = await firestore
              .collection('borrowingRequests')
              .doc(chairBorrowingRequest.id)
              .get();

          expect(newChairBorrowingRequestDoc.data()!['response'], isNotNull);
          expect(
            newChairBorrowingRequestDoc.data()!['response']['approved'],
            isTrue,
          );
        },
      );
    });
  });
}
