import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/available_items_filter.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/search_field.dart';
import 'package:spare_parts/pages/home_page/inventory_view/filters/user_filter.dart';
import 'package:spare_parts/pages/home_page/inventory_view/selection_actions.dart';
import 'package:spare_parts/services/repositories/repositories.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/inputs/multiselect_button.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';
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
  String _searchQuery = '';
  final List<String> _selectedItemIds = [];
  final searchFieldController = TextEditingController();

  bool get isAdmin => context.read<UserRole>() == UserRole.admin;

  bool get _inSelectionMode => _selectedItemIds.isNotEmpty;

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

  void _handleSelectItem(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryItemRepository = context.read<InventoryItemRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchField(
                  searchFieldController: searchFieldController,
                  onChanged: (value) => setState(() {
                    _searchQuery = value;
                  }),
                ),
              ),
            ),
          ],
        ),
        _inSelectionMode ?
          SelectionActions() :
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              MultiselectButton(
                buttonLabel: 'Item Types',
                values: itemTypes.keys.toList(),
                selectedValues: _selectedItemTypes,
                icon: Icons.filter_list,
                leadingBuilder: (itemType) =>
                    Icon(itemTypes[itemType] ?? itemTypes['Other']!),
                onConfirm: _handleTypesFilterChanged,
              ),
              if (isAdmin) ...[
                SizedBox(width: 10),
                UserFilter(
                  icon: Icons.filter_list,
                  selectedUsers: _selectedBorrowers,
                  onChanged: _handleBorrowersFilterChanged,
                ),
                SizedBox(width: 10),
                AvailableItemsFilter(
                  value: _showOnlyAvailableItems,
                  onPressed: _handleAvailableItemsFilterChanged,
                ),
              ],
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: StreamBuilder<List<InventoryItem>>(
            stream: inventoryItemRepository.getItemsStream(
              withNoBorrower:
                  _selectedBorrowers.isEmpty && _showOnlyAvailableItems,
              whereTypeIn:
                  _selectedItemTypes.isEmpty ? null : _selectedItemTypes,
              whereBorrowerIn:
                  _selectedBorrowers.isEmpty ? null : _selectedBorrowers,
              excludePrivates: !isAdmin,
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

              if (items.isEmpty) {
                return EmptyListState(
                  message: "No inventory items to display...",
                );
              }

              final filteredItems = items.where((item) {
                List<String?> properties = [item.name, item.borrower?.name];
                return properties.where((property) => property != null).any(
                    (property) => property!
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()));
              }).toList();

              filteredItems.sort();

              return ListView(
                children: filteredItems
                    .map((item) => InventoryListItem(
                          item: item,
                          showBorrower: true,
                          selectable: _inSelectionMode,
                          selected: _selectedItemIds.contains(item.id),
                          onSelected: _handleSelectItem,
                        ))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
