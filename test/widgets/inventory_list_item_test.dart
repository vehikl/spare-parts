import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/entities/borrowing_rule.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

import '../helpers/mocks/mock_firebase_auth.dart';
import '../helpers/mocks/mock_user.dart';
import '../helpers/test_helpers.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  testWidgets(
    'Displays name of item',
    (WidgetTester tester) async {
      final testItem = InventoryItem(id: '#re4123', type: 'Chair');

      await pumpPage(Scaffold(body: InventoryListItem(item: testItem)), tester);

      expect(find.text(testItem.id), findsOneWidget);
    },
  );

  testWidgets(
    'Displays current borrower of item',
    (WidgetTester tester) async {
      final borrower = CustomUser(
        uid: 'foo',
        name: 'Foo',
        photoURL: 'example.com',
      );
      final testItem = InventoryItem(
        id: '#re4123',
        type: 'Chair',
        borrower: borrower,
      );

      await pumpPage(
        Scaffold(body: InventoryListItem(item: testItem, showBorrower: true)),
        tester,
      );

      expect(find.text(borrower.name!), findsOneWidget);
    },
  );

  testWidgets(
      'Does not navigate to the item page when a non-admin user clicks an item',
      (WidgetTester tester) async {
    final testItem = InventoryItem(id: '#re4123', type: 'Chair');

    await pumpPage(Scaffold(body: InventoryListItem(item: testItem)), tester);

    final invetoryItemElement = find.ancestor(
      of: find.text('#re4123'),
      matching: find.byType(ListTile),
    );

    await tester.tap(invetoryItemElement);
    await tester.pumpAndSettle();

    expect(find.text('History'), findsNothing);
  });

  group('when borrowing', () {
    group('if a borrowing rule is broken', () {
      late MockFirebaseAuth mockFirebaseAuth;
      late InventoryItem availableItem;

      setUp(() async {
        final currentUser = CustomUser(uid: 'foo');
        mockFirebaseAuth = MockFirebaseAuth();
        final mockUser = MockUser();
        when(mockUser.uid).thenReturn(currentUser.uid);
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        final borrowedItem =
            InventoryItem(id: '#first', type: 'Chair', borrower: currentUser);
        availableItem = InventoryItem(id: '#second', type: 'Chair');

        final itemDocReference =
            await firestore.collection('items').add(borrowedItem.toFirestore());
        await firestore.collection('items').add(availableItem.toFirestore());
        borrowedItem.id = itemDocReference.id;

        final borrowingRule = BorrowingRule(
          type: borrowedItem.type,
          maxBorrowingCount: 1,
        );
        await firestore
            .collection('borrowingRules')
            .add(borrowingRule.toFirestore());
      });

      testWidgets('displays a dialog notifying the user about the restriction',
          (WidgetTester tester) async {
        await pumpPage(
          Scaffold(body: InventoryListItem(item: availableItem)),
          tester,
          userRole: UserRole.user,
          firestore: firestore,
          auth: mockFirebaseAuth,
        );

        final availableChairListItem = find.ancestor(
          of: find.text(availableItem.name),
          matching: find.byType(ListTile),
        );

        final optionsButton = find.descendant(
          of: availableChairListItem,
          matching: find.byIcon(Icons.more_vert),
        );

        await tester.tap(optionsButton);
        await tester.pumpAndSettle();

        final borrowButton = find.text('Borrow');
        await tester.tap(borrowButton);
        await tester.pumpAndSettle();

        expect(
          find.text(
              'You have reached the maximum borrowing count for this item'),
          findsOneWidget,
        );
      });

      testWidgets(
          'and a borrowing request already exists, does not display a dialog',
          (WidgetTester tester) async {
        final borrowingRequest = BorrowingRequest(
          issuer: CustomUser(uid: 'foo'),
          item: BorrowingRequestItem.fromInventoryItem(availableItem),
        );
        await firestore
            .collection('borrowingRequests')
            .add(borrowingRequest.toFirestore());

        await pumpPage(
          Scaffold(body: InventoryListItem(item: availableItem)),
          tester,
          userRole: UserRole.user,
          firestore: firestore,
          auth: mockFirebaseAuth,
        );

        final optionsButton = find.byIcon(Icons.more_vert);

        await tester.tap(optionsButton);
        await tester.pumpAndSettle();

        final borrowButton = find.text('Borrow');
        await tester.tap(borrowButton);
        await tester.pumpAndSettle();

        expect(
          find.text('You have already requested this item'),
          findsOneWidget,
        );
      });
    });
  });
}
