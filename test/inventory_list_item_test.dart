import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

void main() {
  testWidgets(
    'Displays name of item',
    (WidgetTester tester) async {
      const testItem = {'id': 'Chair'};

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InventoryListItem(item: testItem)),
        ),
      );

      expect(find.text(testItem['id']!), findsOneWidget);
    },
  );
}
