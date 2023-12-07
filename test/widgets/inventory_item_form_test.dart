import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/entities/inventory_items/laptop.dart';
import 'package:spare_parts/services/repositories/inventory_item_repository.mocks.dart';
import 'package:spare_parts/services/repositories/user_repository.mocks.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inventory_list_item/inventory_item_form.dart';

import '../helpers/test_helpers.dart';
import '../helpers/tester_extension.dart';

void main() {
  group('InventoryItemForm', () {
    testWidgets('displays an error if no name provided',
        (WidgetTester tester) async {
      await pumpPage(
        InventoryItemForm(formState: InventoryFormState.add),
        tester,
        userRole: UserRole.admin,
      );

      expect(find.text('You must set a name'), findsNothing);

      final addButton = find.text('Save');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.text('You must set a name'), findsOneWidget);
    });

    group('when generating item name', () {
      const userName = 'name';
      final authMock = createAuth(userName: userName);

      testWidgets('generates new name', (WidgetTester tester) async {
        final inventoryItemRepository = MockInventoryItemRepository();
        await pumpPage(
          InventoryItemForm(formState: InventoryFormState.add),
          tester,
          userRole: UserRole.admin,
          inventoryItemRepository: inventoryItemRepository,
          auth: authMock,
        );

        final generateNameButton = find.byIcon(Icons.autorenew);
        await tester.tap(generateNameButton);
        await tester.pumpAndSettle();

        final addButton = find.text('Save');
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        final savedItem = (verify(inventoryItemRepository.add(captureAny))
            .captured
            .single as InventoryItem);
        expect(savedItem.name, 'Desk #1');
      });

      testWidgets('generates name based on the selected type',
          (WidgetTester tester) async {
        final inventoryItemRepository = MockInventoryItemRepository();
        await pumpPage(
          InventoryItemForm(formState: InventoryFormState.add),
          tester,
          userRole: UserRole.admin,
          inventoryItemRepository: inventoryItemRepository,
          auth: authMock,
        );

        const newItemType = 'Chair';
        await tester.selectDropdownOption('Item Type', newItemType);
        final generateNameButton = find.byIcon(Icons.autorenew);
        await tester.tap(generateNameButton);
        await tester.pumpAndSettle();

        final addButton = find.text('Save');
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        final savedItem = (verify(inventoryItemRepository.add(captureAny))
            .captured
            .single as InventoryItem);
        expect(savedItem.name, contains(newItemType));
      });

      testWidgets('generates name with a unique number',
          (WidgetTester tester) async {
        final inventoryItemRepository = MockInventoryItemRepository();
        final firestore = FakeFirebaseFirestore();
        final existingItem = InventoryItem(
          id: '#1',
          name: 'Desk #1',
          type: 'Desk',
          storageLocation: 'Waterloo',
          description: 'Lorem ipsum',
          isPrivate: true,
        );
        await firestore.collection('items').add(existingItem.toFirestore());
        await firestore.collection('meta').doc('itemNameIds').set({
          'Desk': 1,
        });

        await pumpPage(
          InventoryItemForm(formState: InventoryFormState.add),
          tester,
          userRole: UserRole.admin,
          inventoryItemRepository: inventoryItemRepository,
          firestore: firestore,
          auth: authMock,
        );

        final generateNameButton = find.byIcon(Icons.autorenew);
        await tester.tap(generateNameButton);
        await tester.pumpAndSettle();

        final addButton = find.text('Save');
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        final savedItem = (verify(inventoryItemRepository.add(captureAny))
            .captured
            .single as InventoryItem);
        expect(savedItem.name, 'Desk #2');
      });
    });

    testWidgets(
      'fills all the inputs when editing an item',
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
      skip: true, // started failing after new Flutter version
    );

    testWidgets('allows editing extra data if an item is a Laptop',
        (WidgetTester tester) async {
      final laptop = Laptop(
        id: '#145',
        name: 'Laptop 3000',
        storageLocation: 'Waterloo',
        description: 'Lorem ipsum',
        isPrivate: true,
        serial: '123456789',
        purchaseDate: DateTime.now(),
        year: 2000,
        size: 12,
        model: 'Big',
        colour: 'Yellow',
        build: 'Good',
        ram: 64,
        disk: '1GB',
        warranty: 'Will not break for sure',
      );
      await pumpPage(
        InventoryItemForm(formState: InventoryFormState.edit, item: laptop),
        tester,
        userRole: UserRole.admin,
      );

      expect(find.text('Serial Number *'), findsOneWidget);
      expect(find.text(laptop.serial), findsOneWidget);
      expect(find.text('Purchase Date'), findsOneWidget);
      expect(find.text(laptop.formattedPurchaseDate), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
      expect(find.text(laptop.year.toString()), findsOneWidget);
      expect(find.text('Size (In.)'), findsOneWidget);
      expect(find.text(laptop.size.toString()), findsOneWidget);
      expect(find.text('Model'), findsOneWidget);
      expect(find.text(laptop.model!), findsOneWidget);
      expect(find.text('Colour'), findsOneWidget);
      expect(find.text(laptop.colour!), findsOneWidget);
      expect(find.text('Build'), findsOneWidget);
      expect(find.text(laptop.build!), findsOneWidget);
      expect(find.text('RAM (GB)'), findsOneWidget);
      expect(find.text(laptop.ram.toString()), findsOneWidget);
      expect(find.text('Disk'), findsOneWidget);
      expect(find.text(laptop.disk!), findsOneWidget);
      expect(find.text('Warranty'), findsOneWidget);
      expect(find.text(laptop.warranty!), findsOneWidget);
    });

    testWidgets('allows unselecting location', (WidgetTester tester) async {
      const location = 'Waterloo';
      final inventoryItemRepository = MockInventoryItemRepository();
      when(inventoryItemRepository.update(any)).thenAnswer((_) async {});

      final item = InventoryItem(
        id: '#145',
        type: 'Desk',
        storageLocation: location,
      );
      await pumpPage(
        InventoryItemForm(formState: InventoryFormState.edit, item: item),
        tester,
        userRole: UserRole.admin,
        inventoryItemRepository: inventoryItemRepository,
      );

      final locationDropdown = find.text(location);
      await tester.tap(locationDropdown);
      await tester.pumpAndSettle();

      final noLocation = find.text('-- no location --');
      await tester.tap(noLocation);
      await tester.pumpAndSettle();

      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final savedItem = verify(inventoryItemRepository.update(captureAny))
          .captured
          .single as InventoryItem;
      expect(savedItem.storageLocation, isNull);
    });

    testWidgets('allows selecting a borrower', (WidgetTester tester) async {
      final inventoryItemRepository = MockInventoryItemRepository();
      when(inventoryItemRepository.add(any)).thenAnswer((_) async => "");

      final user = CustomUser(uid: 'asd', name: 'Jane Doe');
      final userRepository = MockUserRepository();
      when(userRepository.getAllStream())
          .thenAnswer((_) => Stream.fromIterable([
                [user]
              ]));

      await pumpPage(
        InventoryItemForm(formState: InventoryFormState.add),
        tester,
        userRole: UserRole.admin,
        inventoryItemRepository: inventoryItemRepository,
        userRepository: userRepository,
      );

      await tester.enterTextByLabel('Name *', 'New item');

      final borrowerButton = find.text('Current Borrower');
      await tester.tap(borrowerButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text(user.name!));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final savedItem = verify(inventoryItemRepository.add(captureAny))
          .captured
          .single as InventoryItem;
      expect(savedItem.borrower, isNotNull);
      expect(savedItem.borrower!.uid, user.uid);
      expect(savedItem.borrower!.name, user.name);
    });
  });
}
