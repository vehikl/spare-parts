import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/business_logic/item_action.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/inventory_view/search_field.dart';
import 'package:spare_parts/pages/home_page/inventory_view/user_dropdown.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/inputs/multiselect_button.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({Key? key}) : super(key: key);

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  List<String> _selectedItemTypes = [];
  List<String> _selectedBorrowers = [];
  String _searchQuery = '';

  void _handleTypesFilterChanged(List<String> newTypes) {
    setState(() {
      _selectedItemTypes = newTypes;
    });
  }

  void _handleBorrowersFilterChanged(List<String> newBorrowers) {
    setState(() {
      _selectedBorrowers = newBorrowers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchField(
                  value: _searchQuery,
                  onChanged: (value) => setState(() {
                    _searchQuery = value;
                  }),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              MultiselectButton(
                buttonLabel: 'Item Types',
                values: itemTypes.keys.toList(),
                selectedValues: _selectedItemTypes,
                iconBuilder: (itemType) =>
                    itemTypes[itemType] ?? itemTypes['Other']!,
                onConfirm: _handleTypesFilterChanged,
              ),
              SizedBox(width: 10),
              UserDropdown(
                selectedUsers: _selectedBorrowers,
                onChanged: _handleBorrowersFilterChanged,
              ),
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: StreamBuilder<List<InventoryItem>>(
            stream: firestoreService.getItemsStream(
              withNoBorrower: _selectedBorrowers.isEmpty,
              whereTypeIn:
                  _selectedItemTypes.isEmpty ? null : _selectedItemTypes,
              whereBorrowerIn:
                  _selectedBorrowers.isEmpty ? null : _selectedBorrowers,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorContainer(error: snapshot.error.toString());
              }

              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data!;

              if (items.isEmpty) {
                return EmptyListState(
                  message: "No inventory items to display...",
                );
              }

              final filteredItems = items.where((i) =>
                  i.id.toLowerCase().contains(_searchQuery.toLowerCase()));

              return ListView(
                children: filteredItems
                    .map((item) => InventoryListItem(
                          item: item,
                          actions: [BorrowItemAction()],
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
