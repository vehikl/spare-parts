import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/business_logic/item_action.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({Key? key}) : super(key: key);

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  List<String>? _selectedItemTypes;
  late final Stream<List<InventoryItem>> _itemsStream;
  late final FirestoreService _firestoreService;

  @override
  void initState() {
    _firestoreService = context.read<FirestoreService>();
    _itemsStream = _firestoreService.getItemsStream(
      withNoBorrower: true,
      whereTypesIn: _selectedItemTypes,
    );
    log('creating items stream...');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<List<InventoryItem>>(
        stream: _itemsStream,
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

          log('rendering the list of items...');

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
                    selectedColor: Colors.orange,
                    decoration: BoxDecoration(
                      color: _selectedItemTypes == null
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                    ),
                    buttonText: Text('Item Type'),
                    onConfirm: (results) {
                      setState(() {
                        _selectedItemTypes = results.isEmpty ? null : results;
                      });
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
