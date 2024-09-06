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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _addNewUser() async {
    final name = _nameController.text;
    final email = _emailController.text;

    if (name.isNotEmpty && email.isNotEmpty) {
      final uuid = Uuid();
      await userRepository.add(CustomUser(
        uid: uuid.v1(),
        name: name,
        email: email,
      ));
    }

    _nameController.clear();
    _emailController.clear();
  }

  UserRepository get userRepository => context.read<UserRepository>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: Key('name'),
            controller: _nameController,
            decoration: InputDecoration(hintText: 'User name'),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            key: Key('email'),
            controller: _emailController,
            decoration: InputDecoration(hintText: 'User email'),
          ),
        ),
        SizedBox(width: 10),
        IconButton.filled(icon: Icon(Icons.add), onPressed: _addNewUser),
      ],
    );
  }
}
