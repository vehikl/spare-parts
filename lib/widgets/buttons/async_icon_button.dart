import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AsyncIconButton extends StatefulWidget {
  final IconData icon;
  final AsyncCallback onPressed;
  final Color? color;

  const AsyncIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  State<AsyncIconButton> createState() => _AsyncIconButtonState();
}

class _AsyncIconButtonState extends State<AsyncIconButton> {
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
    return IconButton(
      icon: _loading
          ? CircularProgressIndicator(color: widget.color)
          : Icon(widget.icon),
      onPressed: _loading ? () {} : _handlePress,
      color: widget.color,
    );
  }
}
