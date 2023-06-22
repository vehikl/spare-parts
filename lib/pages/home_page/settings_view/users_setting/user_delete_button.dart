import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/services/repositories/repositories.dart';
import 'package:spare_parts/widgets/dialogs/danger_dialog.dart';

class UserDeleteButton extends StatelessWidget {
  final CustomUser user;
  const UserDeleteButton({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final userRepository = context.read<UserRepository>();

    return IconButton(
      icon: Icon(
        Icons.delete,
        color: Theme.of(context).colorScheme.error,
      ),
      onPressed: () => showDialog(
        context: context,
        builder: (context) => DangerDialog(
          title: 'Delete user',
          valueName: 'name of the user',
          value: user.name ?? '<no name>',
          onConfirm: () => userRepository.delete(user),
        ),
      ),
    );
  }
}
