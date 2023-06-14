import 'package:flutter/material.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/pages/home_page/settings_view/users_setting/user_form.dart';

class UserEditButton extends StatelessWidget {
  final CustomUser user;
  const UserEditButton({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () => showDialog(
        context: context,
        builder: (context) => UserForm(user: user),
      ),
    );
  }
}
