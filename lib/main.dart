import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/home_page/home_page.dart';
import 'package:spare_parts/pages/signin_page.dart';
import 'package:spare_parts/services/callable_service.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/utilities/helpers.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureEmulators();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Stream<User?> _authStream;

  @override
  void initState() {
    _authStream = FirebaseAuth.instance.authStateChanges();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirestoreService>(
            create: (_) => FirestoreService(FirebaseFirestore.instance)),
        Provider<CallableService>(create: (_) => CallableService())
      ],
      child: MaterialApp(
        title: 'Spare Parts',
        theme: ThemeData(
          primarySwatch: kVehiklMaterialColor,
          buttonTheme: ButtonThemeData(
            alignedDropdown: true,
          ),
        ),
        home: StreamBuilder<User?>(
          stream: _authStream,
          builder: (context, snapshot) {
            final user = snapshot.data;

            if (user?.email != null && user!.email!.endsWith('vehikl.com')) {
              return FutureBuilder<IdTokenResult>(
                future: user.getIdTokenResult(true),
                builder: (context, snap) {
                  if (!snap.hasData) return Scaffold(body: Container());

                  final isAdmin = snap.data?.claims?['role'] == 'admin';
                  return Provider<UserRole>(
                    create: (context) =>
                        isAdmin ? UserRole.admin : UserRole.user,
                    child: HomePage(),
                  );
                },
              );
            }

            return const SignInPage();
          },
        ),
      ),
    );
  }
}
