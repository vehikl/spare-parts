import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/dtos/user_dto.dart';
import 'package:spare_parts/pages/home_page/settings_view/settings_view.dart';
import 'package:spare_parts/services/callable_service.mocks.dart';
import 'package:spare_parts/utilities/constants.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Set admins button', () {
    testWidgets(
      'Displays a success snackbar when admins are successfully set',
      (WidgetTester tester) async {
        final callableService = MockCallableService();
        final user1 = UserDto(
          id: 'first',
          name: 'First',
          role: UserRole.user,
        );
        final user2 = UserDto(
          id: 'second',
          name: 'Second',
          role: UserRole.admin,
        );
        when(callableService.getUsers())
            .thenAnswer((_) async => [user1, user2]);

        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          callableService: callableService,
        );

        await tester.tap(find.text('Set admins'));
        await tester.pump();

        await tester.tap(find.text(user1.name));
        await tester.tap(find.text('Select'));
        await tester.pumpAndSettle();

        expect(find.text('Successfuly modified admins'), findsOneWidget);
      },
    );
  });
}
