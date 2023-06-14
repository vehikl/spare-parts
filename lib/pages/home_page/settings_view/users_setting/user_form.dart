import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/services/repositories/repositories.dart';

class UserForm extends StatefulWidget {
  final CustomUser user;
  const UserForm({super.key, required this.user});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  UserRepository get userRepository => context.read<UserRepository>();
  final userNameConstroller = TextEditingController();

  @override
  void initState() {
    userNameConstroller.text = widget.user.name ?? '';
    super.initState();
  }

  Future<void> _handleSave() async {
    await userRepository.update(
      widget.user.uid,
      CustomUser(
        uid: widget.user.uid,
        name: userNameConstroller.text,
        photoURL: widget.user.photoURL,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit user'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: userNameConstroller,
            decoration: InputDecoration(labelText: 'Name'),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: _handleSave,
          child: Text('Save'),
        ),
      ],
    );
  }
}
