import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/dtos/user_dto.dart';
import 'package:spare_parts/services/callable_service.dart';
import 'package:spare_parts/widgets/inputs/multiselect_button.dart';

class UserFilter extends StatelessWidget {
  final List<String> selectedUsers;
  final void Function(List<String>) onChanged;

  const UserFilter({
    super.key,
    required this.selectedUsers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final callableService = context.watch<CallableService>();

    return FutureBuilder<List<UserDto>>(
      future: callableService.getUsers(),
      builder: (context, snap) {
        if (!snap.hasData || snap.hasError) {
          return SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 3),
          );
        }

        final users = snap.data!;

        return MultiselectButton(
          buttonLabel: 'Borrowers',
          values: users.map((u) => u.id).toList(),
          selectedValues: selectedUsers,
          onConfirm: onChanged,
          labelBuilder: (uid) =>
              users.singleWhere((user) => user.id == uid).name,
        );
      },
    );
  }
}
