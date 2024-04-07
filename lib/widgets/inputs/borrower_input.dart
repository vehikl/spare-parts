import 'package:flutter/material.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/widgets/dialogs/user_selection_dialog.dart';
import 'package:spare_parts/widgets/user_avatar.dart';

class BorrowerInput extends StatelessWidget {
  final CustomUser? borrower;
  final Function(CustomUser?) onSelected;

  const BorrowerInput({
    super.key,
    required this.onSelected,
    required this.borrower,
  });

  Future _handleSelectBorrower(BuildContext context) async {
    final selectedUsers = await showDialog<List<CustomUser>>(
        context: context,
        builder: (context) {
          return UserSelectionDialog(
            isSingleSelection: true,
            selectedUsers: borrower == null ? [] : [borrower!],
            title: 'Select a Borrower',
          );
        });

    if (selectedUsers == null || selectedUsers.isEmpty) {
      return onSelected(null);
    }

    onSelected(selectedUsers.first);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          borrower == null ? null : UserAvatar(photoUrl: borrower?.photoURL),
      title: Text('Current Borrower'),
      subtitle: Text(borrower?.name ?? '-- no borrower --'),
      onTap: () => _handleSelectBorrower(context),
    );
  }
}
