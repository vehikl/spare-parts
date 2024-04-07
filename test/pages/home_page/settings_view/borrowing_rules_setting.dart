import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/borrowing_rule.dart';
import 'package:spare_parts/pages/home_page/settings_view/borrowing_rules_setting/borrowing_rules_setting.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/dialogs/value_selection_dialog.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('Borrowing rules setting', () {
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    tearDown(() async {
      await deleteAllData(firestore);
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
          Scaffold(body: BorrowingRulesSetting()),
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
        final borrowingRule = BorrowingRule(type: 'Desk', maxBorrowingCount: 2);
        await firestore
            .collection('borrowingRules')
            .add(borrowingRule.toFirestore());

        await pumpPage(
          Scaffold(body: BorrowingRulesSetting()),
          tester,
          firestore: firestore,
        );

        final borrowingCount = borrowingRule.maxBorrowingCount;
        expect(find.text(borrowingCount.toString()), findsOneWidget);
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pumpAndSettle();

        expect(find.text((borrowingCount + 1).toString()), findsOneWidget);
      },
    );

    testWidgets(
      'Can decrease the borrowing limit',
      (WidgetTester tester) async {
        final borrowingRule = BorrowingRule(type: 'Desk', maxBorrowingCount: 2);
        await firestore
            .collection('borrowingRules')
            .add(borrowingRule.toFirestore());

        await pumpPage(
          Scaffold(body: BorrowingRulesSetting()),
          tester,
          firestore: firestore,
        );

        final borrowingCount = borrowingRule.maxBorrowingCount;
        expect(find.text(borrowingCount.toString()), findsOneWidget);
        await tester.tap(find.byIcon(Icons.remove).first);
        await tester.pumpAndSettle();

        expect(find.text((borrowingCount - 1).toString()), findsOneWidget);
      },
    );

    testWidgets(
      'Shows a delete button if the borrowing limit is 1',
      (WidgetTester tester) async {
        final borrowingRule = BorrowingRule(type: 'Desk', maxBorrowingCount: 2);
        await firestore
            .collection('borrowingRules')
            .add(borrowingRule.toFirestore());

        await pumpPage(
          Scaffold(body: BorrowingRulesSetting()),
          tester,
          firestore: firestore,
        );

        expect(find.byIcon(Icons.remove), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsNothing);

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.remove), findsNothing);
        expect(find.byIcon(Icons.delete), findsOneWidget);
      },
    );

    testWidgets(
      'Can create a new borrowing rule',
      (WidgetTester tester) async {
        final rule = BorrowingRule(type: 'Chair', maxBorrowingCount: 3);
        await firestore.collection('borrowingRules').add(rule.toFirestore());

        await pumpPage(
          Scaffold(body: BorrowingRulesSetting()),
          tester,
          firestore: firestore,
        );

        await tester.tap(find.byIcon(Icons.add_box));
        await tester.pumpAndSettle();

        expect(find.text(itemTypes.keys.first), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      },
    );

    testWidgets(
      'Picks the first unoccupied item type when creating a new borrowing rule',
      (WidgetTester tester) async {
        const firstN = 5;
        for (final type in itemTypes.keys.take(firstN)) {
          await firestore.collection('borrowingRules').add(BorrowingRule(
                type: type,
                maxBorrowingCount: 1,
              ).toFirestore());
        }

        await pumpPage(
          Scaffold(body: BorrowingRulesSetting()),
          tester,
          firestore: firestore,
        );

        await tester.tap(find.byIcon(Icons.add_box));
        await tester.pumpAndSettle();

        expect(find.text(itemTypes.keys.elementAt(firstN)), findsOneWidget);
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
          Scaffold(body: BorrowingRulesSetting()),
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
        final borrowingRule = BorrowingRule(type: 'Desk', maxBorrowingCount: 1);
        await firestore
            .collection('borrowingRules')
            .add(borrowingRule.toFirestore());

        await pumpPage(
          Scaffold(body: BorrowingRulesSetting()),
          tester,
          firestore: firestore,
        );

        await tester.tap(find.byIcon(Icons.edit).first);
        await tester.pumpAndSettle();

        const newType = 'Monitor';
        await tester.tap(find.text(newType));
        await tester.tap(find.text('Select'));
        await tester.pumpAndSettle();

        expect(find.text(borrowingRule.type), findsNothing);
        expect(find.text(newType), findsOneWidget);
      },
    );

    testWidgets(
      'Can not set the borrowing rule type to an existing type',
      (WidgetTester tester) async {
        final firstBorrowingRule =
            BorrowingRule(type: 'Desk', maxBorrowingCount: 1);
        final secondBorrowingRule =
            BorrowingRule(type: 'Chair', maxBorrowingCount: 3);

        // add in reverse order
        await firestore
            .collection('borrowingRules')
            .add(secondBorrowingRule.toFirestore());
        await firestore
            .collection('borrowingRules')
            .add(firstBorrowingRule.toFirestore());

        await pumpPage(
          Scaffold(body: BorrowingRulesSetting()),
          tester,
          firestore: firestore,
        );

        await tester.tap(find.byIcon(Icons.edit).first);
        await tester.pumpAndSettle();

        final existingType = secondBorrowingRule.type;
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