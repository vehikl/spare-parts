import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/home_page.dart';

class MockUser extends Mock implements User {
  // this is needed to satisfy the "Null" related error when calling `thenAnswer`
  // referenced from here: https://github.com/dart-lang/mockito/blob/master/NULL_SAFETY_README.md
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) {
    return super.noSuchMethod(
      Invocation.getter(#uri),
      returnValue: Future.value(MockIdTokenResult())
    );
  }
}

class MockIdTokenResult extends Mock implements IdTokenResult {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() async {
  final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  final user = MockUser();
  final token = MockIdTokenResult();

  when(token.claims).thenReturn({'role': 'admin'});
  when(user.getIdTokenResult()).thenAnswer((_) => Future.value(token));
  when(auth.currentUser).thenReturn(user);

  Future<void> pumpHomePage(WidgetTester tester) async {
    await tester.pumpWidget(Provider<FirebaseAuth>(
      create: (context) => auth,
      child: Provider<FirebaseFirestore>(
        create: (context) => firestore,
        child: MaterialApp(home: HomePage()),
      ),
    ));

    await tester.idle();
    await tester.pump();
  }

  testWidgets('Shows the add button if the user is an admin',
      (WidgetTester tester) async {
    when(token.claims).thenReturn({'role': 'admin'});
    await pumpHomePage(tester);

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Hides the add button if the user is not an admin',
      (WidgetTester tester) async {
    when(token.claims).thenReturn({});
    await pumpHomePage(tester);

    expect(find.byIcon(Icons.add), findsNothing);
  });
}
