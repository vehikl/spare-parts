import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AsyncElevatedButton extends StatefulWidget {
  final String text;
  final AsyncCallback onPressed;

  const AsyncElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<AsyncElevatedButton> createState() => _AsyncElevatedButtonState();
}

class _AsyncElevatedButtonState extends State<AsyncElevatedButton> {
  bool _loading = false;

  void _handlePress() async {
    try {
      setState(() => _loading = true);
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _loading ? () {} : _handlePress,
      child: _loading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
                strokeWidth: 2,
              ),
            )
          : Text(widget.text),
    );
  }
}
