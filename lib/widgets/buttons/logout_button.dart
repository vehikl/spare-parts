import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogoutButton extends StatelessWidget {
  final bool popOnSuccess;
  final bool iconOnly;
  const LogoutButton({super.key, this.popOnSuccess = false, this.iconOnly = false});

  void _handleSignOut(BuildContext context) async {
    final auth = context.read<FirebaseAuth>();
    await auth.signOut();
    if (popOnSuccess) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return IconButton(
        onPressed: () => _handleSignOut(context),
        icon: const Icon(Icons.logout),
      );
    }

    return ElevatedButton.icon(
      label: Text('Logout'),
      onPressed: () => _handleSignOut(context),
      icon: const Icon(Icons.logout),
    );
  }
}
