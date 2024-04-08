import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/available_items_filter.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/item_type_filter.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/user_filter.dart';
import 'package:spare_parts/utilities/constants.dart';

class InventoryViewFilters extends StatelessWidget {
  const InventoryViewFilters({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isAdmin = context.watch<UserRole>() == UserRole.admin;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 5),
          ItemTypeFilter(),
          if (isAdmin) ...[
            SizedBox(width: 10),
            UserFilter(),
            SizedBox(width: 10),
            AvailableItemsFilter(),
          ],
        ],
      ),
    );
  }
}
