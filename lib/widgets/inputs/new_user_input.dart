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
  bool _isDirty = false;

  void _addNewUser() async {
    setState(() {
      _isDirty = true;
    });

    if (_formValid) {
      final name = _nameController.text;
      final email = _emailController.text;

      final uuid = Uuid();
      await userRepository.add(CustomUser(
        uid: uuid.v1(),
        name: name,
        email: email,
      ));

      _nameController.clear();
      _emailController.clear();
    }
  }

  UserRepository get userRepository => context.read<UserRepository>();

  String? _getNameError() {
    if (_nameController.text.isEmpty) {
      return 'User name is required';
    }

    return null;
  }

  String? _getEmailError() {
    if (_emailController.text.isEmpty) {
      return 'Email is required';
    }

    return null;
  }

  Text? getErrorWidget(String? Function() errorGetter) {
    if (!_isDirty) {
      return null;
    }

    final error = errorGetter();
    if (error == null) {
      return null;
    }

    return Text(error);
  }

  bool get _formValid {
    final nameError = _getNameError();
    final emailError = _getEmailError();

    return nameError == null && emailError == null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: Key('name'),
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'User name',
                  error: getErrorWidget(_getNameError),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                key: Key('email'),
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'User email',
                  error: getErrorWidget(_getEmailError),
                ),
              ),
            ),
            SizedBox(width: 10),
            IconButton.filled(icon: Icon(Icons.add), onPressed: _addNewUser),
          ],
        ),
        SizedBox(height: _formValid ? 30 : 0),
      ],
    );
  }
}
