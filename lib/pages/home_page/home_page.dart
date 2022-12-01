import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/home_page/borrowed_items_view.dart';
import 'package:spare_parts/pages/home_page/inventory_view/inventory_view.dart';
import 'package:spare_parts/pages/home_page/settings_view/settings_view.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/add_inventory_item_button.dart';
import 'package:spare_parts/widgets/custom_layout_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedBottomNavItemIndex = 0;
  final PageController pageController = PageController();

  _handleSignOut() {
    final auth = context.read<FirebaseAuth>();
    auth.signOut();
  }

  _handleSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Inventory'),
            actions: [
              TextButton.icon(
                label: Text('Logout'),
                onPressed: _handleSignOut,
                icon: const Icon(Icons.logout),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
            ],
          ),
          body: Center(child: SettingsView()),
        ),
      ),
    );
  }

  void _onBottomNavItemTapped(int index) {
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );

    setState(() {
      _selectedBottomNavItemIndex = index;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedBottomNavItemIndex = index;
    });
  }

  bool get isAdmin => context.read<UserRole>() == UserRole.admin;

  @override
  Widget build(BuildContext context) {
    return CustomLayoutBuilder(builder: (context, layout) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Inventory'),
          actions: [
            if (layout == LayoutType.desktop && isAdmin)
              TextButton.icon(
                label: Text('Settings'),
                onPressed: _handleSettings,
                icon: Icon(Icons.settings),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
            TextButton.icon(
              label: Text('Logout'),
              onPressed: _handleSignOut,
              icon: const Icon(Icons.logout),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ],
        ),
        floatingActionButton: AddInventoryItemButton(),
        body: layout == LayoutType.desktop
            ? SizedBox(
                child: Row(
                  children: const [
                    Expanded(child: InventoryView()),
                    Expanded(child: BorrowedItemsView())
                  ],
                ),
              )
            : PageView(
                controller: pageController,
                onPageChanged: _onPageChanged,
                children: [
                  InventoryView(),
                  BorrowedItemsView(),
                  if (isAdmin) SettingsView()
                ],
              ),
        bottomNavigationBar: layout == LayoutType.desktop
            ? null
            : BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Inventory'),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.backpack_outlined),
                    label: 'Borrowed Items',
                  ),
                  if (isAdmin)
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                ],
                currentIndex: _selectedBottomNavItemIndex,
                selectedItemColor: Colors.amber[800],
                onTap: _onBottomNavItemTapped,
              ),
      );
    });
  }
}
