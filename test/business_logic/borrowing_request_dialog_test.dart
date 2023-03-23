import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/business_logic/borrowing_request_dialog.dart';
import 'package:spare_parts/utilities/constants.dart';

import '../helpers/mocks/mock_firebase_auth.dart';
import '../helpers/mocks/mock_user.dart';
import '../helpers/test_helpers.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  final mockFirebaseAuth = MockFirebaseAuth();

  testWidgets(
    'when submitting a borrowing request shows a confirmation message and creates a db record',
    (WidgetTester tester) async {
      const userId = 'user123';
      const itemId = 'item123';

      final userMock = MockUser();

      when(userMock.uid).thenReturn(userId);
      when(mockFirebaseAuth.currentUser).thenReturn(userMock);

      await pumpPage(
        Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              child: Text('Launch'),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => BorrowingRequestDialog(itemId: itemId),
              ),
            );
          }),
        ),
        tester,
        userRole: UserRole.user,
        firestore: firestore,
        auth: mockFirebaseAuth,
      );
      await tester.pumpAndSettle();

      final launchButton = find.text('Launch');
      await tester.tap(launchButton);
      await tester.pumpAndSettle();

      expect(
        find.text('You have reached the maximum borrowing count for this item'),
        findsOneWidget,
      );

      final submitButton = find.text('Submit request');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Your borrowing request was submitted successfully. You will be notified when a decision is made.',
        ),
        findsOneWidget,
      );

      final borrowingRequests = await firestore
          .collection('borrowingRequests')
          .where('issuerId', isEqualTo: userId)
          .where('itemId', isEqualTo: itemId)
          .get();

      expect(borrowingRequests.docs, hasLength(1));
    },
  );
}
