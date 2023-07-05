import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spare_parts/dtos/user_dto.dart';
import 'package:spare_parts/pages/home_page/settings_view/settings_view.dart';
import 'package:spare_parts/services/callable_service.mocks.dart';
import 'package:spare_parts/utilities/constants.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('Set Admins button', () {
    MockCallableService mockCallableService = MockCallableService();
    final user1 = UserDto(id: 'first', name: 'First', role: UserRole.user);
    final user2 = UserDto(id: 'second', name: 'Second', role: UserRole.admin);

    setUp(() {
      mockCallableService = MockCallableService();
      when(mockCallableService.getUsers())
          .thenAnswer((_) async => [user1, user2]);
    });

    group('displays a list of users', () {
      testWidgets(
        'excluding the current user',
        (WidgetTester tester) async {
          final mockFirebaseAuth = createAuth(uid: user1.id);

          await pumpPage(
            Scaffold(body: SettingsView()),
            tester,
            callableService: mockCallableService,
            auth: mockFirebaseAuth,
          );

          await tester.tap(find.text('Set Admins'));
          await tester.pump();

          expect(find.text(user1.name), findsNothing);
          expect(find.text(user2.name), findsOneWidget);
        },
      );

      testWidgets(
        'with admins selected',
        (WidgetTester tester) async {
          await pumpPage(
            Scaffold(body: SettingsView()),
            tester,
            callableService: mockCallableService,
          );

          await tester.tap(find.text('Set Admins'));
          await tester.pump();
          final user1Finder = find.ancestor(
            of: find.text(user1.name),
            matching: find.byType(ListTile),
          );
          final user1ListTile = tester.firstWidget(user1Finder) as ListTile;
          final user2Finder = find.ancestor(
            of: find.text(user2.name),
            matching: find.byType(ListTile),
          );
          final user2ListTile = tester.firstWidget(user2Finder) as ListTile;
          expect(user1ListTile.selected, false);
          expect(user2ListTile.selected, true);
        },
      );
    });

    testWidgets(
      'displays a success snackbar when admins are successfully set',
      (WidgetTester tester) async {
        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          callableService: mockCallableService,
        );

        await tester.tap(find.text('Set Admins'));
        await tester.pump();

        await tester.tap(find.text(user1.name));
        await tester.tap(find.text('Select'));
        await tester.pumpAndSettle();

        expect(find.text('Successfuly modified admins'), findsOneWidget);
      },
    );

    testWidgets(
      'displays an error snackbar if fails to set admins',
      (WidgetTester tester) async {
        when(mockCallableService.setAdmins(any)).thenThrow(Exception());

        await pumpPage(
          Scaffold(body: SettingsView()),
          tester,
          callableService: mockCallableService,
        );

        await tester.tap(find.text('Set Admins'));
        await tester.pump();

        await tester.tap(find.text(user1.name));
        await tester.tap(find.text('Select'));
        await tester.pumpAndSettle();

        expect(find.text('Something went wrong while modifying admins'),
            findsOneWidget);
      },
    );
  });
}
