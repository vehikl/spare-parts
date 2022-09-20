import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/business_logic/item_action.dart';
import 'package:spare_parts/dtos/user_dto.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/callable_service.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    final callableService = context.watch<CallableService>();

    return Center(
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

          return Column(
            children: [
              Row(
                children: [
                  MultiSelectDialogField<String>(
                    chipDisplay: MultiSelectChipDisplay.none(),
                    items: inventoryItems.entries
                        .map((entry) => MultiSelectItem(entry.key, entry.key))
                        .toList(),
                    title: Text('Item Type'),
                    selectedColor: Theme.of(context).primaryColor,
                    decoration: BoxDecoration(
                      color: _selectedItemTypes == null
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                    ),
                    buttonText: Text('Item Type'),
                    onConfirm: (results) {
                      setState(() {
                        _selectedItemTypes = results.isEmpty ? null : results;
                      });
                    },
                  ),
                  FutureBuilder<List<UserDto>>(
                    future: callableService.getUsers(),
                    builder: (context, snap) {
                      if (!snap.hasData || snap.hasError) {
                        return CircularProgressIndicator();
                      }

                      final users = snap.data!;
                      final dropdownItems = [
                        DropdownMenuItem(value: null, child: Text("None")),
                        ...users.map((user) => DropdownMenuItem(
                              value: user.id,
                              child: Text(user.name),
                            ))
                      ];

                      return DropdownButton<String?>(
                        value: _selectedBorrower,
                        items: dropdownItems,
                        onChanged: (selection) {
                          setState(() {
                            _selectedBorrower = selection;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
              items.isEmpty
                  ? EmptyListState(message: "No inventory items to display...")
                  : Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return InventoryListItem(
                            item: items[index],
                            actions: [BorrowItemAction()],
                          );
                        },
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
