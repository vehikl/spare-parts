import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/dtos/user_dto.dart';
import 'package:spare_parts/services/callable_service.dart';
import 'package:spare_parts/utilities/constants.dart';

class UserDropdown extends StatelessWidget {
  final String? value;
  final void Function(String?) onChanged;

  const UserDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  bool get isValueSet => value != null;

  @override
  Widget build(BuildContext context) {
    final callableService = context.watch<CallableService>();

    return Row(
      children: [
        Icon(Icons.person),
        FutureBuilder<List<UserDto>>(
          future: callableService.getUsers(),
          builder: (context, snap) {
            if (!snap.hasData || snap.hasError) {
              return SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 3),
              );
            }

            final users = snap.data!;
            final dropdownItems = [
              DropdownMenuItem(value: null, child: Text("No borrower")),
              ...users.map((user) => DropdownMenuItem(
                    value: user.id,
                    child: Text(user.name),
                  ))
            ];

            return DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: value,
                items: dropdownItems,
                onChanged: onChanged,
                borderRadius: kBorderRadius,
              ),
            );
          },
        ),
      ],
    );
  }
}
