import 'package:flutter/material.dart';

class ErrorContainer extends StatelessWidget {
  final String error;
  const ErrorContainer({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).colorScheme.error,
      ),
      padding: const EdgeInsets.all(16),
      child: SelectableText(error),
    );
  }
}
