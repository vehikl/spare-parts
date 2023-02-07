import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatefulWidget {
  final String? error;

  const SignInPage({this.error, Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String? _error;

  handleSignIn(BuildContext context) async {
    String? signInError;

    try {
      if (kIsWeb) {
        await _signInOnWeb();
      } else {
        await _signInOnMobile();
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      signInError = e.message;
    } catch (e) {
      print(e.toString());
      signInError = 'Authentication error: $e';
    }

    setState(() {
      _error = signInError;
    });
  }

  Future<void> _signInOnWeb() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();
    await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  Future<void> _signInOnMobile() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw Exception('Failed to sign in with Google');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
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
