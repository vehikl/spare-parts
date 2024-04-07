import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/inventory_item.dart';
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
  List<String> _selectedItemTypes = [];
  List<String> _selectedBorrowers = [];
  late bool _showOnlyAvailableItems;
  bool _inSelectionMode = false;
  int _itemsLimit = kItemsPerPage;

  bool get isAdmin => context.read<UserRole>() == UserRole.admin;

  @override
  void initState() {
    _showOnlyAvailableItems = !isAdmin;

    super.initState();
  }

  void _handleTypesFilterChanged(List<String> newTypes) {
    setState(() => _selectedItemTypes = newTypes);
  }

  void _handleBorrowersFilterChanged(List<String> newBorrowers) {
    setState(() => _selectedBorrowers = newBorrowers);
  }

  void _handleAvailableItemsFilterChanged() {
    setState(() => _showOnlyAvailableItems = !_showOnlyAvailableItems);
  }

  void _handleSelectionModeChanged(bool inSelectionMode) {
    setState(() => _inSelectionMode = inSelectionMode);
  }

  void _loadMoreItems() {
    setState(() => _itemsLimit += kItemsPerPage);
  }

  @override
  Widget build(BuildContext context) {
    final inventoryItemRepository = context.read<InventoryItemRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_inSelectionMode) ...[
          InventoryViewFilters(
            selectedItemTypes: _selectedItemTypes,
            selectedBorrowers: _selectedBorrowers,
            showOnlyAvailableItems: _showOnlyAvailableItems,
            handleTypesFilterChanged: _handleTypesFilterChanged,
            handleBorrowersFilterChanged: _handleBorrowersFilterChanged,
            handleAvailableItemsFilterChanged:
                _handleAvailableItemsFilterChanged,
          ),
          Divider(),
        ],
        Expanded(
          child: StreamBuilder<List<InventoryItem>>(
            stream: inventoryItemRepository.getItemsStream(
              withNoBorrower: _showOnlyAvailableItems,
              whereTypeIn:
                  _selectedItemTypes.isEmpty ? null : _selectedItemTypes,
              whereBorrowerIn:
                  _selectedBorrowers.isEmpty ? null : _selectedBorrowers,
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
                    (index) => InventoryListItemLoading(hasAuthor: isAdmin),
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
          ),
        ),
      ],
    );
  }
}
