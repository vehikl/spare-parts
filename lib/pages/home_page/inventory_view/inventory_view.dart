import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/business_logic/item_action.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/inventory_view/item_type_multi_select.dart';
import 'package:spare_parts/pages/home_page/inventory_view/user_dropdown.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({Key? key}) : super(key: key);

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  List<String>? _selectedItemTypes;
  String? _selectedBorrower;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  void _handleTypesFilterChanged(List<String> newTypes) {
    setState(() {
      _selectedItemTypes = newTypes.isEmpty ? null : newTypes;
    });
  }

  void _handleBorrowerFilterChanged(String? newBorrower) {
    setState(() {
      _selectedBorrower = newBorrower;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

    return Column(
      children: [
        Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: 'Search'),
              onChanged: (newValue) {
                setState(() {
                  searchQuery = newValue;
                });
              },
            ),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ItemTypeMultiSelect(
                value: _selectedItemTypes,
                onConfirm: _handleTypesFilterChanged,
              ),
              SizedBox(width: 10),
              UserDropdown(
                value: _selectedBorrower,
                onChanged: _handleBorrowerFilterChanged,
              ),
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: StreamBuilder<List<InventoryItem>>(
            stream: firestoreService.getItemsStream(
              withNoBorrower: _selectedBorrower == null,
              whereTypeIn: _selectedItemTypes,
              whereBorrowerIs: _selectedBorrower,
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

              final filteredItems =
                  items.where((i) => i.id.contains(searchQuery));

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
