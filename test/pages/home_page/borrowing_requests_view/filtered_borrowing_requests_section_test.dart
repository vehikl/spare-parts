import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/entities/borrowing_response.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view/borrowing_request_list_item.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view/filtered_borrowing_requests_section.dart';
import 'package:spare_parts/utilities/constants.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('Filtered Borrowing Requests Section', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    const user = CustomUser(uid: 'qwe123', name: 'John Doe');
    final authMock = createAuth(uid: user.uid, userName: user.name!);

    final pendingRequest = BorrowingRequest(
      item: BorrowingRequestItem(id: 'pending_item', type: 'Chair'),
      issuer: user,
    );

    final processedRequest = BorrowingRequest(
      item: BorrowingRequestItem(id: 'processed_item', type: 'Chair'),
      issuer: user,
      response: BorrowingResponse(
        decisionMaker: CustomUser(uid: '2', name: 'Bar'),
        approved: false,
      ),
    );

    setUp(() async {
      await firestore
          .collection('borrowingRequests')
          .add(pendingRequest.toFirestore());
      await firestore
          .collection('borrowingRequests')
          .add(processedRequest.toFirestore());
    });

    tearDown(() async {
      await deleteAllData(firestore);
    });

    group('when showing pending requests', () {
      testWidgets('shows correct empty message', (WidgetTester tester) async {
        await deleteAllData(firestore);

        await pumpPage(
          Scaffold(
            body: FilteredBorrowingRequestsSection(showProcessed: false),
          ),
          tester,
          auth: authMock,
          firestore: firestore,
          userRole: UserRole.admin,
        );

        expect(
          find.text("You haven't requested any items yet..."),
          findsOneWidget,
        );
      });

      testWidgets('shows pending requests', (WidgetTester tester) async {
        await pumpPage(
          Scaffold(
            body: FilteredBorrowingRequestsSection(showProcessed: false),
          ),
          tester,
          auth: authMock,
          firestore: firestore,
          userRole: UserRole.admin,
        );

        await tester.pumpAndSettle();

        expect(find.text(processedRequest.item.id), findsNothing);
        expect(find.text(pendingRequest.item.id), findsOneWidget);
      });

      testWidgets('shows actions on items', (WidgetTester tester) async {
        await pumpPage(
          Scaffold(
            body: FilteredBorrowingRequestsSection(showProcessed: false),
          ),
          tester,
          auth: authMock,
          firestore: firestore,
          userRole: UserRole.admin,
        );

        await tester.pumpAndSettle();

        final pendingItem = find.ancestor(
          of: find.text(pendingRequest.item.id),
          matching: find.byType(BorrowingRequestListItem),
        );

        final optionsButton = find.descendant(
          of: pendingItem,
          matching: find.byIcon(Icons.more_vert),
        );

        expect(optionsButton, findsOneWidget);
      });
    });

    group('when showing processed requests', () {
      testWidgets('shows correct empty message', (WidgetTester tester) async {
        await deleteAllData(firestore);

        await pumpPage(
          Scaffold(
            body: FilteredBorrowingRequestsSection(showProcessed: true),
          ),
          tester,
          auth: authMock,
          firestore: firestore,
          userRole: UserRole.admin,
        );

        expect(find.text("No processed requests found..."), findsOneWidget);
      });

      testWidgets('shows processed requests', (WidgetTester tester) async {
        await pumpPage(
          Scaffold(
            body: FilteredBorrowingRequestsSection(showProcessed: true),
          ),
          tester,
          auth: authMock,
          firestore: firestore,
          userRole: UserRole.admin,
        );

        await tester.pumpAndSettle();

        expect(find.text(pendingRequest.item.id), findsNothing);
        expect(find.text(processedRequest.item.id), findsOneWidget);
      });

      testWidgets('does not show actions on items',
          (WidgetTester tester) async {
        await pumpPage(
          Scaffold(
            body: FilteredBorrowingRequestsSection(showProcessed: true),
          ),
          tester,
          auth: authMock,
          firestore: firestore,
          userRole: UserRole.admin,
        );

        await tester.pumpAndSettle();

        final pendingItem = find.ancestor(
          of: find.text(processedRequest.item.id),
          matching: find.byType(BorrowingRequestListItem),
        );

        final optionsButton = find.descendant(
          of: pendingItem,
          matching: find.byIcon(Icons.more_vert),
        );

        expect(optionsButton, findsNothing);
      });
    });
  });
}
