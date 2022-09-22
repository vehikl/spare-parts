import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/dtos/user_dto.dart';
import 'package:spare_parts/services/callable_service.dart';

class UserDropdown extends StatelessWidget {
  final String? value;
  final void Function(String?) onChanged;

  const UserDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final callableService = context.watch<CallableService>();

    return FutureBuilder<List<UserDto>>(
      future: callableService.getUsers(),
      builder: (context, snap) {
        if (!snap.hasData || snap.hasError) {
          return CircularProgressIndicator();
        }

        final users = snap.data!;
        final dropdownItems = [
          DropdownMenuItem(value: null, child: Text("None")),
          ...users.map((user) => DropdownMenuItem(
                value: user.id,
                child: Text(user.name),
              ))
        ];

        return DropdownButton<String?>(
          value: value,
          items: dropdownItems,
          onChanged: onChanged,
        );
      },
    );
  }
}
