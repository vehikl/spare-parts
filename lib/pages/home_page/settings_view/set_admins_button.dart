import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/services/callable_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/utilities/helpers.dart';
import 'package:spare_parts/widgets/dialogs/value_selection_dialog.dart';
import 'package:spare_parts/widgets/title_text.dart';
import 'package:spare_parts/widgets/user_avatar.dart';

class SetAdminsButton extends StatefulWidget {
  const SetAdminsButton({super.key});

  @override
  State<SetAdminsButton> createState() => _SetAdminsButtonState();
}

class _SetAdminsButtonState extends State<SetAdminsButton> {
  bool _loading = false;

  void _handleSetAdmins(BuildContext context) async {
    setState(() {
      _loading = true;
    });

    final callableService = context.read<CallableService>();
    final auth = context.read<FirebaseAuth>();
    final users = await callableService.getUsers();
    final otherUsers =
        users.where((user) => user.id != auth.currentUser?.uid).toList();

    final newSelectedValues = await showDialog<List<String>?>(
      context: context,
      builder: (context) => ValueSelectionDialog(
        title: 'Pick admins',
        values: otherUsers.map((u) => u.id).toList(),
        selectedValues: otherUsers
            .where((u) => u.role == UserRole.admin)
            .map((u) => u.id)
            .toList(),
        labelBuilder: (uid) =>
            otherUsers.singleWhere((user) => user.id == uid).name,
        leadingBuilder: (uid) {
          final user = otherUsers.singleWhere((user) => user.id == uid);
          return UserAvatar(photoUrl: user.photoUrl);
        },
      ),
    );

    if (newSelectedValues == null) {
      setState(() {
        _loading = false;
      });
      return null;
    }

    try {
      await callableService.setAdmins(newSelectedValues);
      showSuccess(context: context, message: 'Successfuly modified admins');
    } catch (e) {
      showError(
        context: context,
        message: 'Something went wrong while modifying admins',
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleText('Manage Administrators'),
        if (_loading)
          Center(child: CircularProgressIndicator())
        else
          ListTile(
            title: Text('Decide which users have the Admin role'),
            trailing: ElevatedButton(
              onPressed: () => _handleSetAdmins(context),
              child: Text('Set Admins'),
            ),
          ),
      ],
    );
  }
}
