import 'package:flutter/material.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/home_page/inventory_view/selection_actions.dart';
import 'package:spare_parts/widgets/dialogs/print_dialog/print_dialog_web.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

class InventoryViewList extends StatefulWidget {
  final List<InventoryItem> items;
  final String searchQuery;
  final void Function(bool)? onSelectionModeChanged;

  const InventoryViewList({
    super.key,
    required this.items,
    required this.searchQuery,
    this.onSelectionModeChanged,
  });

  @override
  State<InventoryViewList> createState() => _InventoryViewListState();
}

class _InventoryViewListState extends State<InventoryViewList> {
  final List<String> _selectedItemIds = [];
  bool get _inSelectionMode => _selectedItemIds.isNotEmpty;

  void _handleSelectItem(String itemId) {
    final previousListEmpty = _selectedItemIds.isEmpty;
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
    if (_selectedItemIds.isEmpty != previousListEmpty) {
      widget.onSelectionModeChanged?.call(_inSelectionMode);
    }
  }

  void _handleOnSelectAll() {
    setState(() {
      _selectedItemIds.clear();
      _selectedItemIds.addAll(widget.items.map((item) => item.id));
    });
  }

  void _handleOnDeselectAll() {
    setState(() {
      _selectedItemIds.clear();
    });
    widget.onSelectionModeChanged?.call(false);
  }

  void _handlePrintAll() {
    final selectedItems = widget.items
        .where((item) => _selectedItemIds.contains(item.id))
        .toList();
    showDialog(
      context: context,
      builder: (_) => PrintDialog(items: selectedItems),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return EmptyListState(
        message: "No inventory items to display...",
      );
    }

    final filteredItems = widget.items.where((item) {
      List<String?> properties = [item.name, item.borrower?.name];
      return properties.where((property) => property != null).any((property) =>
          property!.toLowerCase().contains(widget.searchQuery.toLowerCase()));
    }).toList();

    filteredItems.sort();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_inSelectionMode) ...[
          SelectionActions(
            onSelectAll: _handleOnSelectAll,
            onDeselectAll: _handleOnDeselectAll,
            onPrintAll: _handlePrintAll,
          ),
          Divider(),
        ],
        ListView(
          shrinkWrap: true,
          children: filteredItems
              .map((item) => InventoryListItem(
                    item: item,
                    showBorrower: true,
                    selectable: _inSelectionMode,
                    selected: _selectedItemIds.contains(item.id),
                    onSelected: _handleSelectItem,
                  ))
              .toList(),
        ),
      ],
    );
  }
}
