import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/widgets/inventory_list_item/item_actions_button.dart';

import '../helpers/test_helpers.dart';

main() {
  group('For admin users', () {
    testWidgets('displays the option to print a label on web',
        (WidgetTester tester) async {
      final testItem = InventoryItem(id: '#re4123', type: 'Chair');
      await pumpPage(Scaffold(body: ItemActionsButton(item: testItem)), tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Print'), kIsWeb ? findsOneWidget : findsNothing);
    });
  });
}
