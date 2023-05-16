import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class InventoryListItemLoading extends StatelessWidget {
  const InventoryListItemLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final randomWidth = 150 + Random().nextDouble() * 250;

    return ListTile(
      leading: Icon(Icons.chair, color: Colors.grey),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              height: 18,
              width: randomWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey,
              )),
        ],
      ),
      trailing: Icon(Icons.more_vert, color: Colors.grey),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF));
  }
}
