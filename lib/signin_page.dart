import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spare_parts/home_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String? _error;

  handleSignIn(BuildContext context) async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    try {
      var user = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'Authentication error';
        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            Text(_error ?? '', style: const TextStyle(color: Colors.red))
          ],
        ),
      ),
    );
  }
}
