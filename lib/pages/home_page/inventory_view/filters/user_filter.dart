import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/dtos/user_dto.dart';
import 'package:spare_parts/services/callable_service.dart';
import 'package:spare_parts/widgets/inputs/multiselect_button.dart';
import 'package:spare_parts/widgets/user_avatar.dart';

class UserFilter extends StatefulWidget {
  final List<String> selectedUsers;
  final void Function(List<String>) onChanged;
  final IconData? icon;

  const UserFilter({
    super.key,
    required this.selectedUsers,
    required this.onChanged,
    this.icon,
  });

  @override
  State<UserFilter> createState() => _UserFilterState();
}

class _UserFilterState extends State<UserFilter> {
  late Future<List<UserDto>> _userQuery;

  @override
  void initState() {
    final callableService = context.read<CallableService>();
    _userQuery = callableService.getUsers();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserDto>>(
      future: _userQuery,
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
          selectedValues: widget.selectedUsers,
          onConfirm: widget.onChanged,
          icon: widget.icon,
          labelBuilder: (uid) =>
              users.singleWhere((user) => user.id == uid).name,
          leadingBuilder: (uid) {
            final user = users.singleWhere((user) => user.id == uid);
            return UserAvatar(photoUrl: user.photoUrl);
          },
        );
      },
    );
  }
}
