import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/factories/inventory_item_factory.dart';
import 'package:spare_parts/pages/home_page/home_page.dart';
import 'package:spare_parts/pages/home_page/inventory_view/inventory_view.dart';
import 'package:spare_parts/pages/item_page/item_page.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/dialogs/user_selection_dialog.dart';
import 'package:spare_parts/widgets/inputs/new_user_input.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';
import 'package:spare_parts/widgets/inventory_list_item/inventory_item_form.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/tester_extension.dart';

void main() {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  late InventoryItem chairItem;
  final inventoryItemFactory = InventoryItemFactory();

  Future<void> saveItemToFirestore(InventoryItem item) async {
    await firestore.collection('items').doc(item.id).set(item.toFirestore());
  }

  setUp(() async {
    chairItem = InventoryItem(
      id: 'Chair#123',
      name: 'The Great Chair',
      type: 'Chair',
    );
    await saveItemToFirestore(chairItem);
  });

  tearDown(() async {
    await deleteAllData(firestore);
  });

  testWidgets('Displays a list of inventory items',
      (WidgetTester tester) async {
    await pumpPage(
      Scaffold(body: InventoryView()),
      tester,
      firestore: firestore,
    );

    expect(find.text(chairItem.name), findsOneWidget);
  });

  group('With private items', () {
    testWidgets('Includes private items for admins',
        (WidgetTester tester) async {
      final privateItem = InventoryItem(
        id: 'Chair#123',
        name: 'The Great Chair',
        type: 'Chair',
        isPrivate: true,
      );
      await firestore
          .collection('items')
          .doc(privateItem.id)
          .set(privateItem.toFirestore());

      await pumpPage(Scaffold(body: InventoryView()), tester,
          firestore: firestore, userRole: UserRole.admin);

      expect(find.text(privateItem.name), findsOneWidget);
    });

    testWidgets('Excludes private items for users',
        (WidgetTester tester) async {
      final privateItem = InventoryItem(
        id: 'Chair#123',
        name: 'The Great Chair',
        type: 'Chair',
        isPrivate: true,
      );
      await firestore
          .collection('items')
          .doc(privateItem.id)
          .set(privateItem.toFirestore());

      await pumpPage(Scaffold(body: InventoryView()), tester,
          firestore: firestore, userRole: UserRole.user);

      expect(find.text(privateItem.name), findsNothing);
    });
  });

  group('Adding a new item', () {
    testWidgets('is disabled for users', (WidgetTester tester) async {
      await pumpPage(
        HomePage(),
        tester,
        userRole: UserRole.user,
        firestore: firestore,
      );

      final fab = find.byIcon(Icons.add);
      expect(fab, findsNothing);
    });

    testWidgets(
      'adds a new item to inventory list',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(Size(800, 1000));

        const itemName = 'Table #3';
        const itemType = 'Desk';
        const itemStorageLocation = 'Waterloo';
        const itemDescription = 'Lorem ipsum';
        const isPrivate = true;

        await pumpPage(
          HomePage(),
          tester,
          userRole: UserRole.admin,
          firestore: firestore,
        );

        final fab = find.byIcon(Icons.add);

        await tester.tap(fab);
        await tester.pumpAndSettle();

        await tester.enterTextByLabel('Name *', itemName);
        await tester.enterTextByLabel('Description', itemDescription);
        await tester.selectDropdownOption('Item Type', itemType);
        await tester.selectDropdownOption(
          'Storage Location',
          itemStorageLocation,
        );
        if (isPrivate) {
          // TODO: there is an issue where this switch is not found due to the height of the form.
          // Scrolling down to the switch did not work.
          await tester.tap(
              find.widgetWithText(SwitchListTile, 'Only visible to admins'));
        }

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        final newItemListItem = find.text(itemName);
        expect(newItemListItem, findsOneWidget);

        await tester.tap(newItemListItem);
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(Card),
            matching: find.textContaining(itemName),
          ),
          findsOneWidget,
        );
        expect(find.text(itemDescription), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(ItemPage),
            matching: find.byIcon(itemTypes[itemType]!),
          ),
          findsOneWidget,
        );
        expect(find.textContaining(itemStorageLocation), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      },
    );
  });

  group('Editing an item', () {
    testWidgets(
      'Edits an inventory item',
      (WidgetTester tester) async {
        final oldItemName = chairItem.name;
        const newItemName = 'Chair#321';

        await pumpPage(
          Scaffold(body: InventoryView()),
          tester,
          userRole: UserRole.admin,
          firestore: firestore,
        );

        final chairListItem = find.ancestor(
          of: find.text(oldItemName),
          matching: find.byType(ListTile),
        );
        final optionsButton = find.descendant(
          of: chairListItem,
          matching: find.byIcon(Icons.more_vert),
        );

        await tester.tap(optionsButton);
        await tester.pumpAndSettle();

        final editButton = find.text('Edit');
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        await tester.enterTextByLabel('Name *', newItemName);
        const newType = 'Desk';
        await tester.selectDropdownOption('Item Type', newType);

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(ListTile),
            matching: find.text(newItemName),
          ),
          findsOneWidget,
        );
        expect(find.text(oldItemName), findsNothing);
        final newItemTypeIcon = find.descendant(
          of: find.byType(InventoryListItem),
          matching: find.byIcon(itemTypes[newType]!),
        );
        expect(newItemTypeIcon, findsOneWidget);
      },
    );

    testWidgets(
      'Saves the initial value of the item id if not updated',
      (WidgetTester tester) async {
        final oldItemName = chairItem.name;
        await pumpPage(
          Scaffold(body: InventoryView()),
          tester,
          userRole: UserRole.admin,
          firestore: firestore,
        );

        final chairListItem = find.ancestor(
          of: find.text(oldItemName),
          matching: find.byType(ListTile),
        );
        final optionsButton = find.descendant(
          of: chairListItem,
          matching: find.byIcon(Icons.more_vert),
        );

        await tester.tap(optionsButton);
        await tester.pumpAndSettle();

        final editButton = find.text('Edit');
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        final saveButton = find.text('Save');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.byType(InventoryItemForm), findsNothing);
        expect(find.text(oldItemName), findsOneWidget);
        final itemTypeIcon = find.descendant(
          of: find.byType(InventoryListItem),
          matching: find.byIcon(Icons.chair),
        );
        expect(itemTypeIcon, findsOneWidget);
      },
    );
  });

  testWidgets(
    'Deletes an item from the list',
    (WidgetTester tester) async {
      await pumpPage(
        Scaffold(body: InventoryView()),
        tester,
        userRole: UserRole.admin,
        firestore: firestore,
      );

      final chairListItem = find.ancestor(
        of: find.text(chairItem.name),
        matching: find.byType(ListTile),
      );
      final optionsButton = find.descendant(
        of: chairListItem,
        matching: find.byIcon(Icons.more_vert),
      );

      await tester.tap(optionsButton);
      await tester.pumpAndSettle();

      final deleteButton = find.text('Delete');
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.text(chairItem.name), findsNothing);
    },
  );

  testWidgets(
    'User can borrow an item from the list',
    (WidgetTester tester) async {
      await pumpPage(
        Scaffold(body: InventoryView()),
        tester,
        userRole: UserRole.user,
        firestore: firestore,
      );

      final chairListItem = find.ancestor(
        of: find.text(chairItem.name),
        matching: find.byType(ListTile),
      );
      final optionsButton = find.descendant(
        of: chairListItem,
        matching: find.byIcon(Icons.more_vert),
      );

      await tester.tap(optionsButton);
      await tester.pumpAndSettle();

      final borrowButton = find.text('Borrow');
      await tester.tap(borrowButton);
      await tester.pumpAndSettle();

      expect(find.text(chairItem.name), findsNothing);
      expect(find.text('Item has been successfully borrowed'), findsOneWidget);
    },
  );

  group('Assigning a borrower', () {
    final user = CustomUser(uid: 'foo', name: 'Foo');

    setUp(() async {
      await firestore.collection('users').add(user.toFirestore());
    });

    testWidgets(
      'can set the borrower on an item',
      (WidgetTester tester) async {
        await pumpPage(
          Scaffold(body: InventoryView()),
          tester,
          userRole: UserRole.admin,
          firestore: firestore,
        );

        var chairListItem = find.ancestor(
          of: find.text(chairItem.name),
          matching: find.byType(ListTile),
        );
        final optionsButton = find.descendant(
          of: chairListItem,
          matching: find.byIcon(Icons.more_vert),
        );

        await tester.tap(optionsButton);
        await tester.pumpAndSettle();

        final assignButton = find.text('Assign');
        await tester.tap(assignButton);
        await tester.pumpAndSettle();

        final userOption = find.text(user.name!);
        await tester.tap(userOption);
        await tester.pumpAndSettle();
        final selectButton = find.text('Select');
        await tester.tap(selectButton);
        await tester.pumpAndSettle();

        chairListItem = find.ancestor(
          of: find.text(chairItem.name),
          matching: find.byType(ListTile),
        );

        final borrower = find.descendant(
          of: chairListItem,
          matching: find.text(user.name!),
        );

        expect(borrower, findsOneWidget);
      },
    );

    testWidgets(
      'can remove the borrower from an item',
      (WidgetTester tester) async {
        final monitorItem = InventoryItem(
          id: 'Monitor#123',
          type: 'Monitor',
          borrower: user,
        );
        await firestore
            .collection('items')
            .doc(monitorItem.id)
            .set(monitorItem.toFirestore());

        await pumpPage(
          Scaffold(body: InventoryView()),
          tester,
          userRole: UserRole.admin,
          firestore: firestore,
        );

        var monitorListItem = find.ancestor(
          of: find.text(monitorItem.id),
          matching: find.byType(ListTile),
        );

        final optionsButton = find.descendant(
          of: monitorListItem,
          matching: find.byIcon(Icons.more_vert),
        );
        await tester.tap(optionsButton);
        await tester.pumpAndSettle();

        final assignButton = find.text('Assign');
        await tester.tap(assignButton);
        await tester.pumpAndSettle();

        final userOption = find.descendant(
          of: find.byType(UserSelectionDialog),
          matching: find.text(user.name!),
        );
        await tester.tap(userOption);
        await tester.pumpAndSettle();

        final selectButton = find.text('Select');
        await tester.tap(selectButton);
        await tester.pumpAndSettle();

        monitorListItem = find.ancestor(
          of: find.text(monitorItem.id),
          matching: find.byType(ListTile),
        );

        final borrower = find.descendant(
          of: monitorListItem,
          matching: find.text(user.name!),
        );

        expect(borrower, findsNothing);
      },
    );

    testWidgets(
      'should not remove the borrower from an item if canceling out from the dialog',
      (WidgetTester tester) async {
        final monitorItem = InventoryItem(
          id: 'Monitor#123',
          type: 'Monitor',
          borrower: user,
        );
        await firestore
            .collection('items')
            .doc(monitorItem.id)
            .set(monitorItem.toFirestore());

        await pumpPage(
          Scaffold(body: InventoryView()),
          tester,
          userRole: UserRole.admin,
          firestore: firestore,
        );

        var monitorListItem = find.ancestor(
          of: find.text(monitorItem.id),
          matching: find.byType(ListTile),
        );

        final optionsButton = find.descendant(
          of: monitorListItem,
          matching: find.byIcon(Icons.more_vert),
        );
        await tester.tap(optionsButton);
        await tester.pumpAndSettle();

        final assignButton = find.text('Assign');
        await tester.tap(assignButton);
        await tester.pumpAndSettle();

        final selectButton = find.text('Cancel');
        await tester.tap(selectButton);
        await tester.pumpAndSettle();

        monitorListItem = find.ancestor(
          of: find.text(monitorItem.id),
          matching: find.byType(ListTile),
        );

        final borrower = find.descendant(
          of: monitorListItem,
          matching: find.text(user.name!),
        );

        expect(borrower, findsOneWidget);
      },
    );

    testWidgets(
      'shows the current borrower as selected',
      (WidgetTester tester) async {
        final monitorItem = InventoryItem(
          id: 'Monitor#123',
          type: 'Monitor',
          borrower: user,
        );
        await firestore
            .collection('items')
            .doc(monitorItem.id)
            .set(monitorItem.toFirestore());

        await pumpPage(
          Scaffold(body: InventoryView()),
          tester,
          userRole: UserRole.admin,
          firestore: firestore,
        );

        var monitorListItem = find.ancestor(
          of: find.text(monitorItem.id),
          matching: find.byType(ListTile),
        );
        final optionsButton = find.descendant(
          of: monitorListItem,
          matching: find.byIcon(Icons.more_vert),
        );

        await tester.tap(optionsButton);
        await tester.pumpAndSettle();

        final assignButton = find.text('Assign');
        await tester.tap(assignButton);
        await tester.pumpAndSettle();

        final userOptionFinder = find.descendant(
          of: find.byType(UserSelectionDialog),
          matching: find.ancestor(
            of: find.text(user.name!),
            matching: find.byType(ListTile),
          ),
        );
        final userOption = tester.firstWidget(userOptionFinder) as ListTile;
        expect(userOption.selected, isTrue);
      },
    );

    testWidgets(
      'can add a user to the list',
      (WidgetTester tester) async {
        await pumpPage(
          Scaffold(body: InventoryView()),
          tester,
          userRole: UserRole.admin,
          firestore: firestore,
        );

        var chairListItem = find.ancestor(
          of: find.text(chairItem.name),
          matching: find.byType(ListTile),
        );

        final optionsButton = find.descendant(
          of: chairListItem,
          matching: find.byIcon(Icons.more_vert),
        );
        await tester.tap(optionsButton);
        await tester.pumpAndSettle();

        final assignButton = find.text('Assign');
        await tester.tap(assignButton);
        await tester.pumpAndSettle();

        var customName = 'Jane Doe';
        var userNameInput = find.byKey(Key('name'));
        await tester.enterText(userNameInput, customName);
        await tester.pumpAndSettle();

        var customEmail = 'jd@vehikl.com';
        var emailInput = find.byKey(Key('email'));
        await tester.enterText(emailInput, customEmail);
        await tester.pumpAndSettle();

        final newUserAddButton = find.byIcon(Icons.add);
        await tester.tap(newUserAddButton);
        await tester.pumpAndSettle();

        final userOption = find.descendant(
          of: find.byType(UserSelectionDialog),
          matching: find.text(customName),
        );
        await tester.tap(userOption);

        await tester.pumpAndSettle();
        final selectButton = find.text('Select');
        await tester.tap(selectButton);
        await tester.pumpAndSettle();

        chairListItem = find.ancestor(
          of: find.text(chairItem.name),
          matching: find.byType(ListTile),
        );

        final borrower = find.descendant(
          of: chairListItem,
          matching: find.text(customName),
        );

        expect(borrower, findsOneWidget);
      },
    );
  });

  group('Filtering items', () {
    group('by type', () {
      testWidgets(
        'shows only items of the selected types',
        (WidgetTester tester) async {
          final deskItem = InventoryItem(id: 'Desk#123', type: 'Desk');
          final monitorItem = InventoryItem(id: 'Monitor#123', type: 'Monitor');
          await firestore
              .collection('items')
              .doc(deskItem.id)
              .set(deskItem.toFirestore());
          await firestore
              .collection('items')
              .doc(monitorItem.id)
              .set(monitorItem.toFirestore());

          await pumpPage(
            Scaffold(body: InventoryView()),
            tester,
            userRole: UserRole.admin,
            firestore: firestore,
          );

          expect(find.text(chairItem.name), findsOneWidget);
          expect(find.text(deskItem.name), findsOneWidget);
          expect(find.text(monitorItem.name), findsOneWidget);

          await tester.tap(find.text('Item Types'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Chair'));
          await tester.tap(find.text('Desk'));

          await tester.tap(find.text('Select'));
          await tester.pumpAndSettle();

          expect(find.text(chairItem.name), findsOneWidget);
          expect(find.text(deskItem.name), findsOneWidget);
          expect(find.text(monitorItem.name), findsNothing);
        },
      );
    });

    group('by user', () {
      testWidgets(
        'shows only items where borrower matches the selected users',
        (WidgetTester tester) async {
          final user1 = CustomUser(uid: 'first', name: 'First');
          final user2 = CustomUser(uid: 'second', name: 'Second');

          firestore.collection('users').doc(user1.uid).set(user1.toFirestore());
          firestore.collection('users').doc(user2.uid).set(user2.toFirestore());

          final item1 = InventoryItemFactory().create(borrower: user1);
          final item2 = InventoryItemFactory().create(borrower: user2);

          saveItemToFirestore(item1);
          saveItemToFirestore(item2);

          await pumpPage(
            Scaffold(body: InventoryView()),
            tester,
            userRole: UserRole.admin,
            firestore: firestore,
          );

          await tester.tap(find.text('Borrowers'));
          await tester.pumpAndSettle();

          await tester.tap(find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text(user1.name!),
          ));

          await tester.tap(find.text('Select'));
          await tester.pumpAndSettle();

          expect(find.text(chairItem.name), findsNothing);
          expect(find.text(item1.name), findsOneWidget);
          expect(find.text(item2.name), findsNothing);
        },
      );
    });

    group('for only available ones', () {
      testWidgets(
        'is enabled by default for admins',
        (WidgetTester tester) async {
          await pumpPage(
            Scaffold(body: InventoryView()),
            tester,
            userRole: UserRole.admin,
            firestore: firestore,
          );

          expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
        },
      );

      testWidgets(
        'is not visible for other users',
        (WidgetTester tester) async {
          await pumpPage(
            Scaffold(body: InventoryView()),
            tester,
            userRole: UserRole.user,
            firestore: firestore,
          );

          expect(find.text('Only available items'), findsNothing);
        },
      );

      testWidgets(
        'shows only the items that have no borrower',
        (WidgetTester tester) async {
          final borrowedItem = InventoryItem(
            id: 'Desk#123',
            type: 'Desk',
            borrower: CustomUser(uid: 'foo'),
          );
          await firestore
              .collection('items')
              .doc(borrowedItem.id)
              .set(borrowedItem.toFirestore());

          await pumpPage(
            Scaffold(body: InventoryView()),
            tester,
            userRole: UserRole.admin,
            firestore: firestore,
          );

          // admins see all items by default
          expect(find.text(chairItem.name), findsOneWidget);
          expect(find.text(borrowedItem.name), findsOneWidget);

          final filterBorrowedItemsCheckbox = find.text('Only available items');
          await tester.tap(filterBorrowedItemsCheckbox);
          await tester.pumpAndSettle();

          expect(find.text(chairItem.name), findsOneWidget);
          expect(find.text(borrowedItem.name), findsNothing);
        },
      );
    });
  });

  group('Loading more items', () {
    testWidgets('loads more items', (tester) async {
      tester.binding.setSurfaceSize(Size(1000, 3000));

      final itemsFromFirstBatch =
          inventoryItemFactory.createMany(kItemsPerPage);
      for (final item in itemsFromFirstBatch) {
        await saveItemToFirestore(item);
      }

      final itemFromNextBatch =
          inventoryItemFactory.create(name: "ZZZ Last item");
      await saveItemToFirestore(itemFromNextBatch);

      await pumpPage(
        Scaffold(body: InventoryView()),
        tester,
        userRole: UserRole.user,
        firestore: firestore,
      );

      expect(find.byType(InventoryListItem), findsNWidgets(kItemsPerPage));
      expect(find.text(itemFromNextBatch.name), findsNothing);

      await tester.tap(find.text('Load More'));
      await tester.pumpAndSettle();

      expect(find.text(itemFromNextBatch.name), findsOneWidget);
    });

    testWidgets('does not allow loading more items when all items were loaded',
        (tester) async {
      tester.binding.setSurfaceSize(Size(1000, 3000));

      final itemsFromFirstBatch =
          inventoryItemFactory.createMany(kItemsPerPage + 1);
      for (final item in itemsFromFirstBatch) {
        await saveItemToFirestore(item);
      }

      await pumpPage(
        Scaffold(body: InventoryView()),
        tester,
        userRole: UserRole.user,
        firestore: firestore,
      );

      await tester.tap(find.text('Load More'));
      await tester.pumpAndSettle();

      expect(find.text('Load More'), findsNothing);
    });
  });
}
