import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/business_logic/borrowing_request_dialog.dart';
import 'package:spare_parts/utilities/constants.dart';

import '../helpers/mocks/mock_firebase_auth.dart';
import '../helpers/test_helpers.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  final mockFirebaseAuth = MockFirebaseAuth();

  testWidgets(
        'can submit a borrowing request',
        (WidgetTester tester) async {
          await pumpPage(
            Scaffold(body: BorrowingRequestDialog()),
            tester,
            userRole: UserRole.user,
            firestore: firestore,
            auth: mockFirebaseAuth,
          );

          final borrowButton = find.text('Submit request');
          await tester.tap(borrowButton);
          await tester.pumpAndSettle();

          expect(
            find.text(
                'Your borrowing request was submitted successfully. You will be notified when a decision is made.'),
            findsOneWidget,
          );
        },
      );
}