import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/widgets/inputs/search_field.dart';
import 'package:spare_parts/widgets/dialogs/value_selection_dialog.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('ValueSelectionDialog', () {
    testWidgets('can be searched by label', (WidgetTester tester) async {
      const firstValue = 'asd';
      const secondValue = 'qwe';

      await pumpPage(
        ValueSelectionDialog<String>(
          selectedValues: [],
          title: 'Select value',
          values: [firstValue, secondValue],
          labelBuilder: (value) => value,
        ),
        tester,
      );

      Finder firstOptionListItem = find.descendant(
        of: find.byType(ListTile),
        matching: find.text(firstValue),
      );
      expect(firstOptionListItem, findsOneWidget);
      Finder secondOptionListItem = find.descendant(
        of: find.byType(ListTile),
        matching: find.text(secondValue),
      );
      expect(secondOptionListItem, findsOneWidget);

      final searchInput = find.descendant(
        of: find.byType(SearchField),
        matching: find.byType(TextField),
      );
      await tester.enterText(searchInput, 'a');
      await tester.pumpAndSettle();

      firstOptionListItem = find.descendant(
        of: find.byType(ListTile),
        matching: find.text(firstValue),
      );
      expect(firstOptionListItem, findsOneWidget);
      secondOptionListItem = find.descendant(
        of: find.byType(ListTile),
        matching: find.text(secondValue),
      );
      expect(secondOptionListItem, findsNothing);
    });
  });
}
