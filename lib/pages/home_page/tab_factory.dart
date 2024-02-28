import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/borrowed_items_view.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view/borrowing_requests_view.dart';
import 'package:spare_parts/pages/home_page/inventory_view/inventory_view.dart';
import 'package:spare_parts/pages/home_page/settings_view/settings_view.dart';
import 'package:spare_parts/widgets/title_text.dart';

class TabFactory {
  bool isAdmin;
  bool isDesktop;

  TabFactory({required this.isAdmin, required this.isDesktop});

  List<BottomNavigationBarItem> getBottomNavBarItems() {
    return getTabs()
        .map(
          (tab) => BottomNavigationBarItem(
            icon: Icon(tab.activeIcon),
            activeIcon: Icon(tab.inactiveIcon),
            label: tab.title,
          ),
        )
        .toList();
  }

  List<Widget> getPages() {
    return getTabs().map((tab) => tab.widget).toList();
  }

  List<Widget> getDesktopPages() {
    final List<Widget> pages = [];
    final tabs = getTabs();

    for (var i = 0; i < tabs.length; i++) {
      pages.add(Expanded(
        child: Column(
          children: [
            TitleText(tabs[i].title),
            Expanded(child: tabs[i].widget),
          ],
        ),
      ));
      
      if (i != tabs.length - 1) {
        pages.add(VerticalDivider());
      }
    }

    return pages;
  }

  List<String> getPageTitles() {
    return getTabs().map((tab) => tab.title).toList();
  }

  List<TabInfo> getTabs() {
    final tabs = [
      TabInfo(
        title: 'Inventory',
        activeIcon: Icons.home_outlined,
        inactiveIcon: Icons.home,
        widget: InventoryView(),
        ordinal: isDesktop
            ? 1
            : isAdmin
                ? 1
                : 2,
      ),
      TabInfo(
        title: 'My Items',
        activeIcon: Icons.backpack_outlined,
        inactiveIcon: Icons.backpack,
        widget: BorrowedItemsView(),
        ordinal: isDesktop
            ? 2
            : isAdmin
                ? 2
                : 1,
      ),
      TabInfo(
        title: 'Borrowing Requests',
        activeIcon: Icons.waving_hand_outlined,
        inactiveIcon: Icons.waving_hand,
        widget: BorrowingRequestsView(),
        ordinal: 3,
      ),
      TabInfo(
        title: 'Settings',
        activeIcon: Icons.settings_outlined,
        inactiveIcon: Icons.settings,
        widget: SettingsView(),
        ordinal: isDesktop ? -1 : 4,
      ),
    ];

    final activeTabs = tabs.where((tab) => tab.ordinal != -1).toList();
    activeTabs.sort((tab1, tab2) => tab1.ordinal - tab2.ordinal);
    return activeTabs;
  }
}

class TabInfo {
  final String title;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final int ordinal;
  Widget widget;

  TabInfo({
    required this.title,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.widget,
    required this.ordinal,
  });
}
