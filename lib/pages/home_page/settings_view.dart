import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/dtos/user_dto.dart';
import 'package:spare_parts/pages/home_page/inventory_view/user_dropdown.dart';
import 'package:spare_parts/services/callable_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/inputs/multiselect_dialog.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _handleSetAdmins(BuildContext context) async {
    final callableService = context.read<CallableService>();
    final users = await callableService.getUsers();

    final newSelectedValues = await showDialog<List<String>?>(
      context: context,
      builder: (context) => MultiselectDialog(
        title: 'Pick a new admin',
        values: users.map((u) => u.id).toList(),
        selectedValues: users
            .where((u) => u.role == UserRole.admin)
            .map((u) => u.id)
            .toList(),
        labelBuilder: (uid) => users.singleWhere((user) => user.id == uid).name,
        leadingBuilder: (uid) {
          final user = users.singleWhere((user) => user.id == uid);
          if (user.photoUrl == null || user.photoUrl == '') {
            return Icon(Icons.person);
          }

          return CircleAvatar(
            foregroundImage: NetworkImage(user.photoUrl!),
          );
        },
      ),
    );

    if (newSelectedValues == null) return;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Settings'),
        ElevatedButton(
          onPressed: () => _handleSetAdmins(context),
          child: Text('Set admins'),
        )
      ],
    );
  }
}
