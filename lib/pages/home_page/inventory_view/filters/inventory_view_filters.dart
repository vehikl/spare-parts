import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/available_items_filter.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/item_type_filter.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/user_filter.dart';
import 'package:spare_parts/utilities/constants.dart';

class InventoryViewFilters extends StatelessWidget {
  final List<String> selectedItemTypes;
  final List<String> selectedBorrowers;
  final bool showOnlyAvailableItems;
  final void Function(List<String>) handleTypesFilterChanged;
  final void Function(List<String>) handleBorrowersFilterChanged;
  final void Function() handleAvailableItemsFilterChanged;

  const InventoryViewFilters({
    super.key,
    required this.selectedItemTypes,
    required this.selectedBorrowers,
    required this.showOnlyAvailableItems,
    required this.handleTypesFilterChanged,
    required this.handleBorrowersFilterChanged,
    required this.handleAvailableItemsFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isAdmin = context.watch<UserRole>() == UserRole.admin;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ItemTypeFilter(
            selectedItemTypes: selectedItemTypes,
            onChanged: handleTypesFilterChanged,
          ),
          if (isAdmin) ...[
            SizedBox(width: 10),
            UserFilter(
              icon: Icons.filter_list,
              selectedUsers: selectedBorrowers,
              onChanged: handleBorrowersFilterChanged,
            ),
            SizedBox(width: 10),
            AvailableItemsFilter(
              value: showOnlyAvailableItems,
              onPressed: handleAvailableItemsFilterChanged,
            ),
          ],
        ],
      ),
    );
  }
}
