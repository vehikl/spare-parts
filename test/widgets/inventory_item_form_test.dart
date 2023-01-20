import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/inventory_item.dart';
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

    testWidgets(
      'Fills all the inputs when editing an item',
      (WidgetTester tester) async {
        final item = InventoryItem(
          id: '#145',
          name: 'Desk 3000',
          type: 'Desk',
          storageLocation: 'Waterloo',
          description: 'Lorem ipsum',
          isPrivate: true,
        );
        await pumpPage(
          InventoryItemForm(formState: InventoryFormState.edit, item: item),
          tester,
          userRole: UserRole.admin,
        );

        expect(find.text(item.id), findsOneWidget);
        expect(find.text(item.name), findsOneWidget);
        expect(find.text(item.type), findsOneWidget);
        expect(find.text(item.storageLocation!), findsOneWidget);
        expect(find.text(item.description!), findsOneWidget);
        final isPrivateSwitch =
            find.widgetWithText(SwitchListTile, 'Only visible to admins');
        final isPrivateSwitchValue =
            tester.widget<SwitchListTile>(isPrivateSwitch).value;
        expect(item.isPrivate, isPrivateSwitchValue);
      },
    );
  });
}
