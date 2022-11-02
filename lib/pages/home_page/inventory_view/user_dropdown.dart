import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/dtos/user_dto.dart';
import 'package:spare_parts/pages/home_page/inventory_view/multiselect_button.dart';
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
          values: users.map((u) => u.name).toList(),
          selectedValues: value == null ? [] : [value!],
          onConfirm: (selectedValues) =>
              onChanged(selectedValues.isEmpty ? null : selectedValues.first),
          label: 'Borrowers',
        );
      },
    );
  }
}
