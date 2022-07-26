import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/pages/home_page/inventory_view.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/models/inventory_item.dart';
import 'package:spare_parts/widgets/inventory_item_form.dart';
import 'package:spare_parts/widgets/inventory_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedBottomNavItemIndex = 0;
  final PageController pageController = PageController();

  handleSignOut(FirebaseAuth auth) {
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

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirebaseFirestore>();
    final auth = context.read<FirebaseAuth>();
    final userRole = context.read<UserRole>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            onPressed: () => handleSignOut(auth),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: userRole == UserRole.admin
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return const InventoryItemForm(
                      formState: InventoryFormState.add,
                    );
                  },
                );
              },
            )
          : null,
      body: PageView(
        controller: pageController,
        onPageChanged: _onPageChanged,
        children: const [
          InventoryView(),
          Center(
            child: Text('Borrowed items'),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.backpack_outlined), label: 'borrowed items'),
        ],
        currentIndex: _selectedBottomNavItemIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onBottomNavItemTapped,
      ),
    );
  }
}
