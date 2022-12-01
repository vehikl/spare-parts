import 'package:flutter/material.dart';

enum LayoutType { mobile, tablet, desktop }

class CustomLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, LayoutType layoutType) builder;

  const CustomLayoutBuilder({super.key, required this.builder});

  LayoutType _getLayoutType(BoxConstraints constraints) {
    if (constraints.maxWidth < 640) return LayoutType.mobile;
    if (constraints.minWidth < 1024) return LayoutType.tablet;
    return LayoutType.desktop;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, _getLayoutType(constraints));
      },
    );
  }
}
