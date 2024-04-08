import 'package:flutter/foundation.dart';
import 'package:spare_parts/entities/custom_user.dart';

class InventoryViewFilterSelection extends ChangeNotifier {
  List<String> selectedItemTypes = [];
  List<CustomUser> selectedBorrowers = [];
  bool showOnlyAvailableItems = false;

  InventoryViewFilterSelection({
    this.selectedItemTypes = const [],
    this.selectedBorrowers = const [],
    this.showOnlyAvailableItems = false,
  });

  void updateSelectedItemTypes(List<String> selectedItemTypes) {
    this.selectedItemTypes = selectedItemTypes;
    notifyListeners();
  }

  void updateSelectedBorrowers(List<CustomUser> selectedBorrowers) {
    this.selectedBorrowers = selectedBorrowers;
    notifyListeners();
  }

  void toggleShowOnlyAvailableItems() {
    showOnlyAvailableItems = !showOnlyAvailableItems;
    notifyListeners();
  }
}
