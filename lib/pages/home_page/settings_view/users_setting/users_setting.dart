import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/pages/home_page/settings_view/users_setting/user_form.dart';
import 'package:spare_parts/services/repositories/user_repository.dart';
import 'package:spare_parts/widgets/inputs/new_user_input.dart';
import 'package:spare_parts/widgets/title_text.dart';
import 'package:spare_parts/widgets/user_avatar.dart';

class UsersSetting extends StatelessWidget {
  const UsersSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = context.read<UserRepository>();

    return Column(
      children: [
        TitleText('Users'),
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
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) => UserForm(user: user)),
                    ),
                  );
                },
              );
            },
          ),
        ),
        NewUserInput(),
      ],
    );
  }
}
