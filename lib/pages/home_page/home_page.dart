import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/home_page/borrowed_items_view.dart';
import 'package:spare_parts/pages/home_page/inventory_view/inventory_view.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/add_inventory_item_button.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          TextButton.icon(
            label: Text('Logout'),
            onPressed: _handleSignOut,
            icon: const Icon(Icons.logout),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          )
        ],
      ),
      floatingActionButton: AddInventoryItemButton(),
      body: PageView(
        controller: pageController,
        onPageChanged: _onPageChanged,
        children: const [
          InventoryView(),
          BorrowedItemsView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inventory'),
          BottomNavigationBarItem(
            icon: Icon(Icons.backpack_outlined),
            label: 'Borrowed Items',
          ),
        ],
        currentIndex: _selectedBottomNavItemIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onBottomNavItemTapped,
      ),
    );
  }
}
