import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/pages/home_page/settings_view/users_setting.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('UsersSetting', () {
    testWidgets('displays available users', (WidgetTester tester) async {
      final firestore = FakeFirebaseFirestore();

      final user1 = CustomUser(uid: 'user1', name: 'John Doe');
      final user2 = CustomUser(uid: 'user2', name: 'Jane Doe');

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
  });
}
