import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatefulWidget {
  final String? error;

  const SignInPage({this.error, Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String? _error;

  handleSignIn(BuildContext context) async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();
    String? signInError;

    try {
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } on FirebaseAuthException catch (e) {
      signInError = e.message;
    } catch (e) {
      signInError = 'Authentication error';
    }

    setState(() {
      _error = signInError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => handleSignIn(context),
              child: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? widget.error ?? '',
              style: const TextStyle(color: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}
