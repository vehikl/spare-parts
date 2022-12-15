import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inventory_item_form.dart';

import '../helpers/test_helpers.dart';
import '../helpers/tester_extension.dart';

void main() {
  group('InventoryItemForm', () {
    testWidgets(
      'Displays an error if no ID provided',
      (WidgetTester tester) async {
        await pumpPage(
          InventoryItemForm(formState: InventoryFormState.add),
          tester,
          userRole: UserRole.admin,
        );

        expect(find.text('You must set an ID'), findsNothing);

        await tester.enterTextByLabel('Name', 'foo');

        final addButton = find.text('Save');
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        expect(find.text('You must set an ID'), findsOneWidget);
      },
    );

    testWidgets(
      'Displays an error if no name provided',
      (WidgetTester tester) async {
        await pumpPage(
          InventoryItemForm(formState: InventoryFormState.add),
          tester,
          userRole: UserRole.admin,
        );

        expect(find.text('You must set a name'), findsNothing);

        await tester.enterTextByLabel('ID', 'foo');

        final addButton = find.text('Save');
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        expect(find.text('You must set a name'), findsOneWidget);
      },
    );
  });
}
