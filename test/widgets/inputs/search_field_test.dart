import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inputs/search_field.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('SearchField', () {
    testWidgets('should display a clear button if query is not empty',
        (WidgetTester tester) async {
      await pumpPage(
        Scaffold(body: SearchField(onChanged: (_) {})),
        tester,
        userRole: UserRole.user,
      );

      final searchButton = find.byIcon(Icons.search);
      expect(searchButton, findsOneWidget);

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, '#');
      await tester.pumpAndSettle();

      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);
    });

    testWidgets('should clear search query when clear button tapped',
        (WidgetTester tester) async {
      await pumpPage(
        Scaffold(body: SearchField(onChanged: (_) {})),
        tester,
        userRole: UserRole.user,
      );

      const query = '#';

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, query);
      await tester.pumpAndSettle();

      final clearButton = find.byIcon(Icons.clear);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(find.text(query), findsNothing);
    });
  });
}
