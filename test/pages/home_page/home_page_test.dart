import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/pages/home_page/home_page.dart';
import 'package:spare_parts/utilities/constants.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('Home Page', () {
    testWidgets('renders My Items page when current user is not admin',
        (WidgetTester tester) async {
      await pumpPage(
        HomePage(),
        tester,
        userRole: UserRole.user,
      );

      final matchingTitle = find.descendant(
        of: find.byType(AppBar),
        matching: find.text('My Items'),
      );
      expect(matchingTitle, findsOneWidget);
    });

    testWidgets('renders Inventory page when current user is admin',
        (WidgetTester tester) async {
      await pumpPage(
        HomePage(),
        tester,
        userRole: UserRole.admin,
      );

      final matchingTitle = find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Inventory'),
      );
      expect(matchingTitle, findsOneWidget);
    });
  });
}
