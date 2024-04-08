import 'package:flutter/material.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/widgets/dialogs/user_selection_dialog.dart';
import 'package:spare_parts/widgets/inputs/multiselect_button.dart';

class UserFilter extends StatefulWidget {
  final List<CustomUser> selectedUsers;
  final void Function(List<CustomUser>) onChanged;

  const UserFilter({
    super.key,
    required this.selectedUsers,
    required this.onChanged,
  });

  @override
  State<UserFilter> createState() => _UserFilterState();
}

class _UserFilterState extends State<UserFilter> {
  @override
  Widget build(BuildContext context) {
    return MultiselectButton<CustomUser>(
      buttonLabel: 'Borrowers',
      hasSelection: widget.selectedUsers.isNotEmpty,
      onConfirm: widget.onChanged,
      dialog: UserSelectionDialog(
        selectedUsers: widget.selectedUsers,
        title: 'Pick Borrowers',
      ),
    );
  }
}
