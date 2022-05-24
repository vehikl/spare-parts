import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key, required this.title}) : super(key: key);

  final String title;

  handleSignIn() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    var user = await FirebaseAuth.instance.signInWithPopup(googleProvider);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: handleSignIn,
              child: const Text('Sign in with Google'),
            )
          ],
        ),
      ),
    );
  }
}
