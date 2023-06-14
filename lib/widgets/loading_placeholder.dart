import 'package:flutter/material.dart';

class LoadingPlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const LoadingPlaceholder({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[400],
      ),
    );
  }
}
