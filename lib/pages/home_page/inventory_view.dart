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
  List<String>? _selectedUserIds;

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
          withNoBorrower: true,
          whereTypeIn: _selectedItemTypes,
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
            return EmptyListState(message: "No inventory items to display...");
          }

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

                      return MultiSelectDialogField<String>(
                        chipDisplay: MultiSelectChipDisplay.none(),
                        items: users
                            .map((user) => MultiSelectItem(user.id, user.name))
                            .toList(),
                        title: Text('Users'),
                        selectedColor: Theme.of(context).primaryColor,
                        decoration: BoxDecoration(
                          color: _selectedItemTypes == null
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                        buttonText: Text('Users'),
                        onConfirm: (results) {
                          setState(() {
                            _selectedUserIds = results.isEmpty ? null : results;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
              Expanded(
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
