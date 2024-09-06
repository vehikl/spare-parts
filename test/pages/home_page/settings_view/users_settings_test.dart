import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/pages/home_page/settings_view/users_setting/users_setting.dart';
import 'package:spare_parts/widgets/dialogs/danger_dialog.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/tester_extension.dart';

void main() {
  group('UsersSetting', () {
    final user1 = CustomUser(uid: 'user1', name: 'John Doe');
    final user2 = CustomUser(uid: 'user2', name: 'Jane Doe');
    final firestore = FakeFirebaseFirestore();

    tearDown(() async {
      await deleteAllData(firestore);
    });

    testWidgets('displays available users', (WidgetTester tester) async {
      await firestore.collection('users').add(user1.toFirestore());
      await firestore.collection('users').add(user2.toFirestore());

      await pumpPage(
        Scaffold(body: UsersSetting()),
        tester,
        firestore: firestore,
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('can add a new user', (tester) async {
      await pumpPage(
        Scaffold(body: UsersSetting()),
        tester,
      );

      const name = 'New user';
      var nameInput = find.byKey(Key('name'));
      await tester.enterText(nameInput, name);
      await tester.pumpAndSettle();

      const email = 'new.user@test.com';
      var emailInput = find.byKey(Key('email'));
      await tester.enterText(emailInput, email);
      await tester.pumpAndSettle();

      final newUserAddButton = find.byIcon(Icons.add);
      await tester.tap(newUserAddButton);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text(name),
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not add a new user without an email', (tester) async {
      await pumpPage(
        Scaffold(body: UsersSetting()),
        tester,
      );

      const customName = 'New user';
      var nameInput = find.byKey(Key('name'));
      await tester.enterText(nameInput, customName);
      await tester.pumpAndSettle();

      final newUserAddButton = find.byIcon(Icons.add);
      await tester.tap(newUserAddButton);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text(customName),
        ),
        findsNothing,
      );
    });

    testWidgets('can edit the name of a user', (tester) async {
      await firestore.collection('users').add(user1.toFirestore());
      await firestore.collection('users').add(user2.toFirestore());

      await pumpPage(
        Scaffold(body: UsersSetting()),
        tester,
        firestore: firestore,
      );

      final user1Option = find.ancestor(
        of: find.text(user1.name!),
        matching: find.byType(ListTile),
      );
      final editButton = find.descendant(
        of: user1Option,
        matching: find.byIcon(Icons.edit),
      );
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      const newName = 'New name';
      await tester.enterTextByLabel('Name', newName);
      await tester.pumpAndSettle();

      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text(newName),
        ),
        findsOneWidget,
      );
    });

    testWidgets('can delete a user', (tester) async {
      await firestore.collection('users').add(user1.toFirestore());
      await firestore.collection('users').add(user2.toFirestore());

      await pumpPage(
        Scaffold(body: UsersSetting()),
        tester,
        firestore: firestore,
      );

      final user1Option = find.ancestor(
        of: find.text(user1.name!),
        matching: find.byType(ListTile),
      );
      final deleteButton = find.descendant(
        of: user1Option,
        matching: find.byIcon(Icons.delete),
      );
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      final confirmationInput = find.descendant(
        of: find.byType(DangerDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(confirmationInput, user1.name!);
      await tester.pumpAndSettle();

      final deleteConfimationButton = find.text('Confirm');
      await tester.tap(deleteConfimationButton);
      await tester.pumpAndSettle();

      expect(find.text(user1.name!), findsNothing);
    });
  });
}
