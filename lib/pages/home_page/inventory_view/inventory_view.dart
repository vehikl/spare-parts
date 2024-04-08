import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/inventory_view_filter_selection.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/inventory_view_filters.dart';
import 'package:spare_parts/pages/home_page/inventory_view/inventory_view_list.dart';
import 'package:spare_parts/services/repositories/repositories.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/inventory_list_item_loading.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({Key? key}) : super(key: key);

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  bool _inSelectionMode = false;
  int _itemsLimit = kItemsPerPage;

  bool get isAdmin => context.read<UserRole>() == UserRole.admin;

  void _handleSelectionModeChanged(bool inSelectionMode) {
    setState(() => _inSelectionMode = inSelectionMode);
  }

  void _loadMoreItems() {
    setState(() => _itemsLimit += kItemsPerPage);
  }

  @override
  Widget build(BuildContext context) {
    final inventoryItemRepository = context.read<InventoryItemRepository>();

    return ChangeNotifierProvider(
      create: (_) => InventoryViewFilterSelection(
        showOnlyAvailableItems: !isAdmin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_inSelectionMode) ...[
            InventoryViewFilters(),
            Divider(),
          ],
          Expanded(
            child: Builder(
              builder: (context) {
                final filterSelection =
                    context.watch<InventoryViewFilterSelection>();
                return StreamBuilder<List<InventoryItem>>(
                  stream: inventoryItemRepository.getItemsStream(
                    withNoBorrower: filterSelection.showOnlyAvailableItems,
                    whereTypeIn: filterSelection.selectedItemTypes.isEmpty
                        ? null
                        : filterSelection.selectedItemTypes,
                    whereBorrowerIn: filterSelection.selectedBorrowers.isEmpty
                        ? null
                        : filterSelection.selectedBorrowers
                            .map((e) => e.uid)
                            .toList(),
                    excludePrivates: !isAdmin,
                    limit: _itemsLimit,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      debugPrint(snapshot.error.toString());
                      debugPrintStack(stackTrace: snapshot.stackTrace);
                      return ErrorContainer(error: snapshot.error.toString());
                    }

                    if (!snapshot.hasData) {
                      return ListView(
                        children: List.generate(
                          10,
                          (index) =>
                              InventoryListItemLoading(hasAuthor: isAdmin),
                        ),
                      );
                    }

                    final items = snapshot.data!;

                    return InventoryViewList(
                      items: items,
                      loadedAllItems: items.length < _itemsLimit,
                      onSelectionModeChanged: _handleSelectionModeChanged,
                      onLoadMore: _loadMoreItems,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
