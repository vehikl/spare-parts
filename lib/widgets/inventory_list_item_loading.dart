import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/loading_placeholder.dart';

class InventoryListItemLoading extends StatelessWidget {
  final bool hasAuthor;
  const InventoryListItemLoading({super.key, this.hasAuthor = false});

  @override
  Widget build(BuildContext context) {
    final titleWidth = 75 + Random().nextDouble() * 200;
    final subtitleWidth = 50 + Random().nextDouble() * 25;
    final randomIdx = Random().nextInt(itemTypes.length);

    final mainColor = Colors.grey[400];

    return ListTile(
      leading: Icon(itemTypes.values.elementAt(randomIdx), color: mainColor),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          LoadingPlaceholder(width: titleWidth, height: 18),
          SizedBox(width: 5),
          if (Random().nextBool()) LoadingPlaceholder(width: 30, height: 18)
        ],
      ),
      subtitle: hasAuthor && Random().nextBool()
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LoadingPlaceholder(width: subtitleWidth, height: 12),
                SizedBox(width: 5),
                LoadingPlaceholder(width: subtitleWidth, height: 12),
              ],
            )
          : null,
      trailing: Icon(Icons.more_vert, color: Colors.grey),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: Colors.grey[200]);
  }
}
