import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/services/repositories/user_repository.dart';
import 'package:spare_parts/widgets/dialogs/dialog_width.dart';
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
  late final List<CustomUser> _newSelectedUsers;

  @override
  void initState() {
    _newSelectedUsers = [...widget.selectedUsers];
    super.initState();
  }

  UserRepository get userRepository => context.read<UserRepository>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: DialogWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => setState(() {
                _newSelectedUsers.clear();
              }),
              child: Text('Clear'),
            ),
            Divider(),
            Flexible(
              child: StreamBuilder<List<CustomUser>>(
                stream: userRepository.getAllStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [CircularProgressIndicator()],
                    );
                  }

                  final users = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return ListTile(
                        title: Text(user.name ?? '<no name>'),
                        leading: UserAvatar(photoUrl: user.photoURL),
                        selected:
                            _newSelectedUsers.any((u) => user.uid == u.uid),
                        selectedTileColor:
                            Theme.of(context).colorScheme.primary,
                        selectedColor: Theme.of(context).colorScheme.onPrimary,
                        enabled: !widget.disabledUids.contains(user.uid),
                        onTap: () {
                          setState(() {
                            if (_newSelectedUsers
                                .any((u) => user.uid == u.uid)) {
                              _newSelectedUsers
                                  .removeWhere((u) => user.uid == u.uid);
                            } else {
                              if (widget.isSingleSelection) {
                                _newSelectedUsers.clear();
                              }
                              _newSelectedUsers.add(user);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            NewUserInput(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _newSelectedUsers);
          },
          child: Text('Select'),
        )
      ],
    );
  }
}
