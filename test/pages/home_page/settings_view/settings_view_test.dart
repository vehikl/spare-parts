import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/dtos/user_dto.dart';
import 'package:spare_parts/entities/borrowing_rule.dart';
import 'package:spare_parts/pages/home_page/settings_view/settings_view.dart';
import 'package:spare_parts/services/callable_service.mocks.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inputs/value_selection_dialog.dart';

import '../../../helpers/mocks/mock_firebase_auth.dart';
import '../../../helpers/mocks/mock_user.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

  group('Set admins button', () {
    MockCallableService mockCallableService = MockCallableService();
    final user1 = UserDto(id: 'first', name: 'First', role: UserRole.user);
    final user2 = UserDto(id: 'second', name: 'Second', role: UserRole.admin);

    setUp(() {
      mockCallableService = MockCallableService();
      when(mockCallableService.getUsers())
          .thenAnswer((_) async => [user1, user2]);
    });

    group('displays a list of users', () {
      testWidgets(
        'excluding the current user',
        (WidgetTester tester) async {
          final mockFirebaseAuth = MockFirebaseAuth();
          final mockUser = MockUser();
          when(mockUser.uid).thenReturn(user1.id);
          when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

          await pumpPage(
            Scaffold(body: SettingsView()),
            tester,
            callableService: mockCallableService,
            auth: mockFirebaseAuth,
          );

          await tester.tap(find.text('Set admins'));
          await tester.pump();

          expect(find.text(user1.name), findsNothing);
          expect(find.text(user2.name), findsOneWidget);
        },
      );

      testWidgets(
        'with admins selected',
        (WidgetTester tester) async {
          await pumpPage(
            Scaffold(body: SettingsView()),
            tester,
            callableService: mockCallableService,
          );

          await tester.tap(find.text('Set admins'));
          await tester.pump();
          final user1Finder = find.ancestor(
            of: find.text(user1.name),
            matching: find.byType(ListTile),
          );
          final user1ListTile = tester.firstWidget(user1Finder) as ListTile;
          final user2Finder = find.ancestor(
            of: find.text(user2.name),
            matching: find.byType(ListTile),
          );
          final user2ListTile = tester.firstWidget(user2Finder) as ListTile;
          expect(user1ListTile.selected, false);
          expect(user2ListTile.selected, true);
        },
      );
    });

    testWidgets(
      'displays a success snackbar when admins are successfully set',
      (WidgetTester tester) async {
        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          callableService: mockCallableService,
        );

        await tester.tap(find.text('Set admins'));
        await tester.pump();

        await tester.tap(find.text(user1.name));
        await tester.tap(find.text('Select'));
        await tester.pumpAndSettle();

        expect(find.text('Successfuly modified admins'), findsOneWidget);
      },
    );

    testWidgets(
      'displays an error snackbar if fails to set admins',
      (WidgetTester tester) async {
        when(mockCallableService.setAdmins(any)).thenThrow(Exception());

        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          callableService: mockCallableService,
        );

        await tester.tap(find.text('Set admins'));
        await tester.pump();

        await tester.tap(find.text(user1.name));
        await tester.tap(find.text('Select'));
        await tester.pumpAndSettle();

        expect(find.text('Something went wrong while modifying admins'),
            findsOneWidget);
      },
    );
  });

  group('Borrowing rules setting', () {
    tearDown(() async {
      deleteAllData(firestore);
    });

    testWidgets(
      'Displays the list of borrowing rules',
      (WidgetTester tester) async {
        final borrowingRules = [
          BorrowingRule(type: 'Chair', maxBorrowingCount: 1),
          BorrowingRule(type: 'Desk', maxBorrowingCount: 2),
        ];
        for (final rule in borrowingRules) {
          await firestore.collection('borrowingRules').add(rule.toFirestore());
        }

        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          firestore: firestore,
        );

        expect(find.text('Borrowing Rules'), findsOneWidget);
        for (var rule in borrowingRules) {
          expect(find.text(rule.type), findsOneWidget);
          expect(find.text(rule.maxBorrowingCount.toString()), findsOneWidget);
        }
      },
    );

    testWidgets(
      'Can increase the borrowing limit',
      (WidgetTester tester) async {
        final borrowingRules = [
          BorrowingRule(type: 'Desk', maxBorrowingCount: 2),
          BorrowingRule(type: 'Chair', maxBorrowingCount: 1),
        ];
        for (final rule in borrowingRules) {
          await firestore.collection('borrowingRules').add(rule.toFirestore());
        }

        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          firestore: firestore,
        );

        final borrowingCount = borrowingRules.first.maxBorrowingCount;
        expect(find.text(borrowingCount.toString()), findsOneWidget);
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pumpAndSettle();

        expect(find.text((borrowingCount + 1).toString()), findsOneWidget);
      },
    );

    testWidgets(
      'Can decrease the borrowing limit',
      (WidgetTester tester) async {
        final borrowingRules = [
          BorrowingRule(type: 'Desk', maxBorrowingCount: 2),
          BorrowingRule(type: 'Chair', maxBorrowingCount: 3),
        ];
        for (final rule in borrowingRules) {
          await firestore.collection('borrowingRules').add(rule.toFirestore());
        }

        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          firestore: firestore,
        );

        final borrowingCount = borrowingRules.first.maxBorrowingCount;
        expect(find.text(borrowingCount.toString()), findsOneWidget);
        await tester.tap(find.byIcon(Icons.remove).first);
        await tester.pumpAndSettle();

        expect(find.text((borrowingCount - 1).toString()), findsOneWidget);
      },
    );

    testWidgets(
      'Shows a delete button if the borrowing limit is 1',
      (WidgetTester tester) async {
        final borrowingRules = [
          BorrowingRule(type: 'Desk', maxBorrowingCount: 2),
          BorrowingRule(type: 'Chair', maxBorrowingCount: 3),
        ];
        for (final rule in borrowingRules) {
          await firestore.collection('borrowingRules').add(rule.toFirestore());
        }

        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          firestore: firestore,
        );

        expect(find.byIcon(Icons.remove), findsNWidgets(2));
        expect(find.byIcon(Icons.delete), findsNothing);

        await tester.tap(find.byIcon(Icons.remove).first);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.remove), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
      },
    );

    testWidgets(
      'Can create a new borrowing rule',
      (WidgetTester tester) async {
        final rule = BorrowingRule(type: 'Chair', maxBorrowingCount: 3);
        await firestore.collection('borrowingRules').add(rule.toFirestore());

        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          firestore: firestore,
        );

        await tester.tap(find.text('Add Rule'));
        await tester.pumpAndSettle();

        expect(find.text(itemTypes.keys.first), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      },
    );

    testWidgets(
      'Can delete a borrowing rule',
      (WidgetTester tester) async {
        final borrowingRules = [
          BorrowingRule(type: 'Desk', maxBorrowingCount: 1),
          BorrowingRule(type: 'Chair', maxBorrowingCount: 3),
        ];
        for (final rule in borrowingRules) {
          await firestore.collection('borrowingRules').add(rule.toFirestore());
        }

        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          firestore: firestore,
        );

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        expect(find.text(borrowingRules.first.type), findsNothing);
      },
    );

    testWidgets(
      'Can edit the borrowing rule type',
      (WidgetTester tester) async {
        final borrowingRules = [
          BorrowingRule(type: 'Desk', maxBorrowingCount: 1),
          BorrowingRule(type: 'Chair', maxBorrowingCount: 3),
        ];
        for (final rule in borrowingRules) {
          await firestore.collection('borrowingRules').add(rule.toFirestore());
        }

        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          firestore: firestore,
        );

        await tester.tap(find.byIcon(Icons.edit).first);
        await tester.pumpAndSettle();

        const newType = 'Monitor';
        await tester.tap(find.text(newType));
        await tester.tap(find.text('Select'));
        await tester.pumpAndSettle();

        expect(find.text(borrowingRules.first.type), findsNothing);
        expect(find.text(newType), findsOneWidget);
      },
    );

    testWidgets(
      'Can not set the borrowing rule type to an existing type',
      (WidgetTester tester) async {
        final borrowingRules = [
          BorrowingRule(type: 'Desk', maxBorrowingCount: 1),
          BorrowingRule(type: 'Chair', maxBorrowingCount: 3),
        ];
        for (final rule in borrowingRules) {
          await firestore.collection('borrowingRules').add(rule.toFirestore());
        }

        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          firestore: firestore,
        );

        await tester.tap(find.byIcon(Icons.edit).first);
        await tester.pumpAndSettle();

        final existingType = borrowingRules.last.type;
        final existingTypeOption = find.descendant(
          of: find.byType(ValueSelectionDialog),
          matching: find.text(existingType),
        );
        await tester.tap(existingTypeOption);
        await tester.tap(find.text('Select'));
        await tester.pumpAndSettle();

        expect(find.text(existingType), findsOneWidget);
      },
    );
  });
}
