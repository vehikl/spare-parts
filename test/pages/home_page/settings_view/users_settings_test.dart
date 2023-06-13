import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/pages/home_page/settings_view/users_setting.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('UsersSetting', () {
    final user1 = CustomUser(uid: 'user1', name: 'John Doe');
    final user2 = CustomUser(uid: 'user2', name: 'Jane Doe');

    testWidgets('displays available users', (WidgetTester tester) async {
      final firestore = FakeFirebaseFirestore();

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

      var customName = 'New user';
      var newUserNameInput = find.byType(TextField);
      await tester.enterText(newUserNameInput, customName);
      await tester.pumpAndSettle();

      final newUserAddButton = find.byIcon(Icons.add);
      await tester.tap(newUserAddButton);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text(customName),
        ),
        findsOneWidget,
      );
    });
  });
}
