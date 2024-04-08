import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/custom_user.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/inventory_view_filter_selection.dart';
import 'package:spare_parts/widgets/dialogs/user_selection_dialog.dart';
import 'package:spare_parts/widgets/inputs/multiselect_button.dart';

class UserFilter extends StatelessWidget {
  const UserFilter({
    super.key
  });

  void onChanged(BuildContext context, List<CustomUser> selectedUsers) {
    final selection = context.read<InventoryViewFilterSelection>();
    selection.updateSelectedBorrowers(selectedUsers);
  }

  @override
  Widget build(BuildContext context) {
    final selectedUsers =
        context.select<InventoryViewFilterSelection, List<CustomUser>>(
            (selection) => selection.selectedBorrowers);

    return MultiselectButton<CustomUser>(
      buttonLabel: 'Borrowers',
      hasSelection: selectedUsers.isNotEmpty,
      onConfirm: (values) => onChanged(context, values),
      dialog: UserSelectionDialog(
        selectedUsers: selectedUsers,
        title: 'Pick Borrowers',
      ),
    );
  }
}
