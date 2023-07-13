import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inventory_list_item/item_actions_button.dart';

import '../helpers/test_helpers.dart';

main() {
  testWidgets(
    'Should not display the "borrow" action for an already borrowed item',
    (WidgetTester tester) async {
      final testItem = InventoryItem(
        id: '#re4123',
        type: 'Chair',
        borrower: CustomUser(uid: 'foo', name: 'Foo'),
      );
      await pumpPage(Scaffold(body: ItemActionsButton(item: testItem)), tester);

      final optionsButton = find.byIcon(Icons.more_vert);
      await tester.tap(optionsButton);
      await tester.pumpAndSettle();

      expect(find.text('Borrow'), findsNothing);
    },
  );

  group('For admin users', () {
    testWidgets('shows the option to release an item',
        (WidgetTester tester) async {
      final testItem = InventoryItem(
        id: '#re4123',
        type: 'Chair',
        borrower: CustomUser(uid: 'foo', name: 'Foo'),
      );
      await pumpPage(
        Scaffold(body: ItemActionsButton(item: testItem)),
        tester,
        userRole: UserRole.admin,
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Release'), findsOneWidget);
    });
  });
}
