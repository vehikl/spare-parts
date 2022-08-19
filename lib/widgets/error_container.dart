import 'package:flutter/material.dart';

class ErrorContainer extends StatelessWidget {
  final String error;
  const ErrorContainer({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.red,
      ),
      padding: const EdgeInsets.all(16),
      child: Text(error),
    );
  }
}
