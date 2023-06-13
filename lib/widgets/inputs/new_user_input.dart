import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/services/repositories/repositories.dart';
import 'package:uuid/uuid.dart';

class NewUserInput extends StatefulWidget {
  const NewUserInput({super.key});

  @override
  State<NewUserInput> createState() => _NewUserInputState();
}

class _NewUserInputState extends State<NewUserInput> {
  final TextEditingController _newUsernameController = TextEditingController();

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
    return TextField(
      key: Key('newUser'),
      controller: _newUsernameController,
      decoration: InputDecoration(
        hintText: 'Add new user',
        suffixIcon: IconButton(icon: Icon(Icons.add), onPressed: _addNewUser),
      ),
    );
  }
}
