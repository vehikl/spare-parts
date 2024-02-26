import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/borrowed_items_view.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view/borrowing_requests_view.dart';
import 'package:spare_parts/pages/home_page/inventory_view/inventory_view.dart';
import 'package:spare_parts/pages/home_page/settings_view/settings_view.dart';
import 'package:spare_parts/widgets/title_text.dart';

class TabFactory {
  static List<BottomNavigationBarItem> getBottomNavBarItems(bool isAdmin) {
    if (isAdmin) {
      return [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.backpack_outlined),
          activeIcon: Icon(Icons.backpack),
          label: 'My Items',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.waving_hand_outlined),
          activeIcon: Icon(Icons.waving_hand),
          label: 'Borrowing Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];
    }

    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.backpack_outlined),
        activeIcon: Icon(Icons.backpack),
        label: 'My Items',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Inventory',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.waving_hand_outlined),
        activeIcon: Icon(Icons.waving_hand),
        label: 'Borrowing Requests',
      ),
    ];
  }

  static List<Widget> getPages(bool isAdmin) {
    if (isAdmin) {
      return [
        InventoryView(),
        BorrowedItemsView(),
        BorrowingRequestsView(),
        SettingsView()
      ];
    }

    return [
      BorrowedItemsView(),
      InventoryView(),
      BorrowingRequestsView(),
    ];
  }

  static List<Widget> getDesktopPages() {
    return [
      Expanded(
        child: Column(
          children: const [
            TitleText('Inventory'),
            Expanded(child: InventoryView()),
          ],
        ),
      ),
      VerticalDivider(),
      Expanded(
        child: Column(
          children: const [
            TitleText('My Items'),
            Expanded(child: BorrowedItemsView())
          ],
        ),
      ),
      VerticalDivider(),
      Expanded(
        child: Column(
          children: const [
            TitleText('Borrowing Requests'),
            Expanded(child: BorrowingRequestsView())
          ],
        ),
      )
    ];
  }

  static List<String> getPageTitles(bool isAdmin) {
    if (isAdmin) {
      return ['Inventory', 'My Items', 'Borrowing Requests', 'Settings'];
    }

    return ['My Items', 'Inventory', 'Borrowing Requests'];
  }
}
