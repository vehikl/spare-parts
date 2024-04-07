import 'package:flutter/material.dart';

class DialogWidth extends StatelessWidget {
  final Widget child;

  const DialogWidth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 300, child: child);
  }
}
