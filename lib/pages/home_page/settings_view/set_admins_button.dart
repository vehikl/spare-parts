import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/services/callable_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inputs/multiselect_dialog.dart';

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
      builder: (context) => MultiselectDialog(
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
          if (user.photoUrl == null || user.photoUrl == '') {
            return Icon(Icons.person);
          }

          return CircleAvatar(
            foregroundImage: NetworkImage(user.photoUrl!),
          );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfuly modified admins'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong while modifying admins'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return CircularProgressIndicator();

    return ElevatedButton(
      onPressed: () => _handleSetAdmins(context),
      child: Text('Set admins'),
    );
  }
}
