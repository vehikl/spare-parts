import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class InventoryListItemLoading extends StatelessWidget {
  const InventoryListItemLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.chair),
      title: Container(
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: Colors.black)),
      trailing: Icon(Icons.more_vert),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF));
  }
}
