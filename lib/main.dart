import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spare_parts/home_page.dart';
import 'package:spare_parts/signin_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const useEmulators = bool.fromEnvironment('USE_EMULATORS');
  if (useEmulators) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  print(
      "Talking to Firebase ${useEmulators ? 'via EMULATORS' : 'in PRODUCTION'}");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Builder(builder: (context) {
          FirebaseAuth.instance.authStateChanges().listen((User? user) async {
            if (user?.email != null && user!.email!.endsWith('vehikl.com')) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomePage()));
            } else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SignInPage()));
              await FirebaseAuth.instance.signOut();
            }
          });
          return const SignInPage();
        }));
  }
}
