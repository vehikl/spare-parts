import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/services/repositories/user_repository.dart';
import 'package:spare_parts/widgets/user_avatar.dart';
import 'package:uuid/uuid.dart';

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
  final TextEditingController _newUsernameController = TextEditingController();

  @override
  void initState() {
    _newSelectedUsers = [...widget.selectedUsers];
    super.initState();
  }

  void _addNewUser() async {
    final newUserName = _newUsernameController.text;
    if (newUserName.isNotEmpty) {
      final uuid = Uuid();
      await userRepository.add(CustomUser(uid: uuid.v1(), name: newUserName));
    }
    _newUsernameController.clear();
  }

  UserRepository get userRepository => context.read<UserRepository>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () => setState(() {
                _newSelectedUsers.clear();
              }),
              child: Text('Clear'),
            ),
            Divider(),
            Expanded(
              child: StreamBuilder<List<CustomUser>>(
                stream: userRepository.getAllStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
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
            TextField(
              key: Key('newUser'),
              controller: _newUsernameController,
              decoration: InputDecoration(
                hintText: 'Add new user',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addNewUser,
                ),
              ),
            ),
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
