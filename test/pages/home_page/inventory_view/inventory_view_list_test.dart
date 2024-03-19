import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/inventory_view/inventory_view_list.dart';
import 'package:spare_parts/pages/home_page/inventory_view/selection_actions.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/dialogs/print_dialog/print_dialog_mobile.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  final chairItem = InventoryItem(
    id: 'Chair#123',
    name: 'The Great Chair',
    type: 'Chair',
  );
  final deskItem = InventoryItem(
    id: 'Desk#145',
    name: "The Great Desk",
    type: 'Desk',
  );

  group('when selecting items', () {
    testWidgets('as a user can not select an item', (tester) async {
      await pumpPage(
        Scaffold(body: InventoryViewList(items: [chairItem, deskItem])),
        tester,
        userRole: UserRole.user,
      );

      final deskListTile = find.ancestor(
        of: find.text(deskItem.name),
        matching: find.byType(ListTile),
      );

      await tester.longPress(deskListTile);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_box), findsNothing);
      expect(find.byType(SelectionActions), findsNothing);
    });

    testWidgets('can select an item', (tester) async {
      await pumpPage(
        Scaffold(body: InventoryViewList(items: [chairItem, deskItem])),
        tester,
        userRole: UserRole.admin,
      );

      final deskListTile = find.ancestor(
        of: find.text(deskItem.name),
        matching: find.byType(ListTile),
      );

      await tester.longPress(deskListTile);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_box), findsOneWidget);
      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    });

    testWidgets('can select all items', (tester) async {
      await pumpPage(
        Scaffold(body: InventoryViewList(items: [chairItem, deskItem])),
        tester,
        userRole: UserRole.admin,
      );

      final deskListTile = find.ancestor(
        of: find.text(deskItem.name),
        matching: find.byType(ListTile),
      );

      await tester.longPress(deskListTile);
      await tester.pumpAndSettle();

      var selectAllButton = find.text('Select All');
      await tester.tap(selectAllButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_box), findsNWidgets(2));
      expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);
    });

    testWidgets('can deselect all items', (tester) async {
      await pumpPage(
        Scaffold(body: InventoryViewList(items: [chairItem, deskItem])),
        tester,
        userRole: UserRole.admin,
      );

      final deskListTile = find.ancestor(
        of: find.text(deskItem.name),
        matching: find.byType(ListTile),
      );

      await tester.longPress(deskListTile);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_box), findsOneWidget);

      var selectAllButton = find.text('Deselect All');
      await tester.tap(selectAllButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_box), findsNothing);
      expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);
    });

    testWidgets('shows a printing dialog for the selected items',
        (tester) async {
      await pumpPage(
        Scaffold(body: InventoryViewList(items: [chairItem, deskItem])),
        tester,
        userRole: UserRole.admin,
      );

      final deskListTile = find.ancestor(
        of: find.text(deskItem.name),
        matching: find.byType(ListTile),
      );

      await tester.longPress(deskListTile);
      await tester.pumpAndSettle();

      final chairListTile = find.ancestor(
        of: find.text(chairItem.name),
        matching: find.byType(ListTile),
      );

      await tester.press(chairListTile);
      await tester.pumpAndSettle();

      var printAllButton = find.text('Print Labels');
      await tester.tap(printAllButton);
      await tester.pumpAndSettle();

      // TODO: assert items in the print dialog
      expect(find.byType(PrintDialog), findsOneWidget);
    });
  });

  testWidgets('can load more items', (tester) async {
    bool loadedMore = false;
    await pumpPage(
      Scaffold(
        body: InventoryViewList(
          items: [chairItem, deskItem],
          loadedAllItems: false,
          onLoadMore: () {
            loadedMore = true;
          },
        ),
      ),
      tester,
      userRole: UserRole.user,
    );

    final loadMoreButton = find.text('Load More');

    await tester.tap(loadMoreButton);
    await tester.pumpAndSettle();

    expect(loadedMore, true);
  });
}
