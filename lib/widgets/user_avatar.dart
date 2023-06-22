import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;

  const UserAvatar({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl == '') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Icon(Icons.person, size: 30),
      );
    }

    return CircleAvatar(
      foregroundImage: NetworkImage(photoUrl!),
      radius: 20,
    );
  }
}
