import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/services/repositories/user_repository.dart';
import 'package:spare_parts/widgets/dialogs/dialog_width.dart';
import 'package:spare_parts/widgets/dialogs/value_selection_dialog.dart';
import 'package:spare_parts/widgets/inputs/new_user_input.dart';
import 'package:spare_parts/widgets/user_avatar.dart';

class UserSelectionDialog extends StatefulWidget {
  final List<CustomUser> selectedUsers;
  final List<String> disabledUids;
  final String title;
  final bool isSingleSelection;

  const UserSelectionDialog({
    super.key,
    required this.selectedUsers,
    required this.title,
    this.isSingleSelection = false,
    this.disabledUids = const [],
  });

  @override
  State<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  UserRepository get userRepository => context.read<UserRepository>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CustomUser>>(
      stream: userRepository.getAllStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return AlertDialog(
            content:
                DialogWidth(child: Center(child: CircularProgressIndicator())),
          );
        }

        final users = snapshot.data!;
        final disabledUsers = widget.disabledUids
            .map((uid) => users.singleWhere((user) => user.uid == uid))
            .toList();

        return ValueSelectionDialog<CustomUser>(
          key: Key(users.map((u) => u.uid).join(',')),
          selectedValues: widget.selectedUsers,
          title: widget.title,
          values: users,
          isSingleSelection: widget.isSingleSelection,
          leadingBuilder: (user) => UserAvatar(photoUrl: user.photoURL),
          labelBuilder: (user) => user.name ?? '<no name>',
          disabledValues: disabledUsers,
          trailing: NewUserInput(),
        );
      },
    );
  }
}
